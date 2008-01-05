From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: A new NFSv4 server...
Date: Sat, 05 Jan 2008 12:46:42 +1100
Message-ID: <477EE182.6020108@melbourne.sgi.com>
References: <477CD231.30603@garzik.org>
	<20080103163200.GB30029@fieldses.org>	<477DC501.3060104@garzik.org>
	<477DD11B.40909@melbourne.sgi.com>
	<477DDA86.6020100@garzik.org> <477DF761.8040306@panasas.com>
	<477E557C.3000104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, NFS list <linux-nfs@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <477E557C.3000104@garzik.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Garzik wrote:
> Benny Halevy wrote:
>>
>> Although It's rather late in the process since the NFSv4 working group
>> is close to putting the NFSv4.1 Internet-draft up for last
>> call, we would certainly appreciate more implementation feedback.
>
>
> I am more than happy to give feedback, though (as you say) it is
> probably too late for substantial feedback to have any large effect.
About five years too late.  Witness the uncomfortable hacks required to
retrofit the extra Sessions fields into the protocol without changing
the basic COMPOUND arguments and results structures, which a minor version
doesn't allow you to do.


>
> My general engineering opinions of pNFS:
>
> * Fills an obvious need:  eliminating the need to copy data through
> the metadata interface to backend storage.  Many clear, tangible
> benefits here.
>
>
> *[...]
> Pick ONE client storage protocol [...] and stick to it.
>
> * [...]
> Pick ONE layout type, and stick to it.
> * pNFS major issue #3: no longer a "closed loop" protocol
>
>
> And when a marketing department advertises "fully NFSv4.1 compliant!"
> on ther company's appliance, it is trivial for any engineer to
> construct another "fully NFSv4.1 compliant" setup -- with equivalent
> authentication, metadata and data sets -- that is not interoperable
> except via the fallback case (copy through the metadata server).
>
> Such interoperability breakdowns are IMO not in the spirit of NFS.

Strongly agreed with all the above.  It's difficult to avoid the
conclusion that the current pNFS spec is designed to allow the
existing parallel filesystem vendors to sell "standards compliant"
solutions that only work with their client software and where all
the MDS and DS machines need to be bought from the same vendor.
If the spec defined a single layout type, and all three protocols
involved were variants of NFSv4.1 and were defined in the spec,
we would have a true open standard.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.
