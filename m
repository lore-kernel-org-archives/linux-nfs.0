From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 21:51:24 +0200
Message-ID: <477E8E3C.4030509@panasas.com>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org>	<477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com> <477DDA86.6020100@garzik.org> <477DF761.8040306@panasas.com> <477E557C.3000104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:12104 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752095AbYADTwB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2008 14:52:01 -0500
In-Reply-To: <477E557C.3000104@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Garzik wrote:
> Benny Halevy wrote:
>> Jeff, taking into account the amount of effort people and different
>> organizations have already put into NFSv4 and NFSv4.1 I wish you could
>> tunnel your inventive energy into making NFSv4.1 better rather than
>> trying to reinvent NFS/RPC/XDR.
>>
>> Although It's rather late in the process since the NFSv4 working group
>> is close to putting the NFSv4.1 Internet-draft up for last
>> call, we would certainly appreciate more implementation feedback.
>
>
> I am more than happy to give feedback, though (as you say) it is 
> probably too late for substantial feedback to have any large effect.
>
> My general engineering opinions of pNFS:
>
> * Fills an obvious need:  eliminating the need to copy data through 
> the metadata interface to backend storage.  Many clear, tangible 
> benefits here.
>
>
> * pNFS major issue #1:  client storage protocol
>
> Storing and retrieving blobs over the network, with strong 
> authentication/integrity/security, is a solved problem.
>
> Pick ONE client storage protocol (HTTP? iSCSI OSD2?), and stick to it. 
> Or maybe HTTP|SCSI but nothing more.  Heck, even BitTorrent w/ auth 
> extensions would be better than yet another protocol for similar 
> purposes (not that I'm advocating BT, just saying...).

Well, two things about that: maybe if pnfs started from scratch this
was the approach that could have been taken but one of the motivating
factors for pNFS (and actually one that I believe will help make it 
successful)
was the desire to replace existing proprietary file system protocols
from several vendors such as EMC, IBM, or Panasas that used
different storage protocols.  Second, providing support for several
kinds of storage is better for customers having existing storage
they want to harness together with pNFS.

>
> Maximize reuse of existing software and mindshare.

That's always good.
>
>
> * pNFS major issue #2:  abandons NFS's "one true generic" path
>
> I believe pNFS violates the "spirit of NFS" by deviating from a 
> defacto assumption found in earlier versions:  data transfer is 
> simple, arbitrary blobs, addressed in the same manner, and sent via 
> the same protocol.
>
> Pick ONE layout type, and stick to it.  Banish all other layout types 
> to other software layers.
I agree wholeheartedly that we should have had one layout data structure 
("layout type" is a loaded
term in the spec...).  This was my position from day one (and even 
before) but unfortunately it wasn't
accepted and each "layout type" got to define it's own layout data 
structure while we could have
defined one generic data structure for mapping files onto all different 
kinds of storage devices
while keeping only the device addressing information private to the 
"layout type" (== storage
protocol class), plus some other data that's internal to the layout 
type, e.g. OSD capabilities.

>
> Protocol conversion servers, firmware, and other softwares can easily 
> convert from a generic layout to something more exotic like OSD or 
> [insert site specific protocol here].
>
> NFS itself should not be delving into low-level storage details like 
> this.  Clients should not need to know low-level details (like stripe 
> sizes).  In Linux, we call this a layering violation.
This is the essence of the layout type concept, implemented as a layout 
driver in the linux nfsv4.1 client
implementation.  The fact that the files layout type definition are part 
of the nfsv4.1 protocol are a mere
fact that the files based layout type uses NFSv4.1 as the storage 
protocol.  It could very well be defined
in a separate RFC exactly like the blocks and objects layout type 
specifications and that can keep its
internal data structures opaque to the generic NFSv4.1 protocol (which 
behaves as a transport protocol
for the layout-type specific data)

>
> Working on kernel storage drivers as I do, I can see the attraction of 
> wanting to do things this way...  but we invented layering and 
> abstraction in computer science for good reasons :)
Yup. I think that the layout driver is the software layer you're looking 
for.
>
>
> * pNFS major issue #3: no longer a "closed loop" protocol
>
> By permitting multiple layout types, and in particular undefined 
> (site-specific) layout types, it is by definition _impossible_ for 
> anyone to claim full protocol interoperability with other 
> implementations.
>
> The number of possible combinations approaches infinity, with obvious 
> consequences on testing, and production software quality.
The non-standard layout types are defined as experimental.  To claim 
interoperability one would
need to publish a suitable specification of the new layout type (see 
"Defining new layout types",
section 22.4 of 
http://www.nfsv4-editor.org/draft-18/draft-ietf-nfsv4-minorversion1-18.html#pnfsiana).
Though I agree that allowing a single file to be accessed with multiple 
layout types (in theory)
complicates testing typically there will be at most one layout type per 
file system.
>
> And when a marketing department advertises "fully NFSv4.1 compliant!" 
> on ther company's appliance, it is trivial for any engineer to 
> construct another "fully NFSv4.1 compliant" setup -- with equivalent 
> authentication, metadata and data sets -- that is not interoperable 
> except via the fallback case (copy through the metadata server).
The compliance with NFSv4.1 is indeed tied with the legacy I/O path, and 
for pnfs, with the files layout type,
as it is a part of NFSv4.1.  Other implementation of NFSv4.1 with pNFS 
over non-files layout types will
have to claim compliance with their respective standards.  For example, 
Panasas's implementation will need
to comply with the OSD standard, iSCSI (or FC), the Object-based pNFS 
RFC, and finally NFSv4.1
> Such interoperability breakdowns are IMO not in the spirit of NFS.
That's a part of making progress IMO...

Benny
>
>     Jeff
>
>

