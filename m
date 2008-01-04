From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 10:49:16 -0500
Message-ID: <477E557C.3000104@garzik.org>
References: <477CD231.30603@garzik.org>
	<20080103163200.GB30029@fieldses.org>	<477DC501.3060104@garzik.org>
	<477DD11B.40909@melbourne.sgi.com>
	<477DDA86.6020100@garzik.org> <477DF761.8040306@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <477DF761.8040306@panasas.com>
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

Benny Halevy wrote:
> Jeff, taking into account the amount of effort people and different
> organizations have already put into NFSv4 and NFSv4.1 I wish you could
> tunnel your inventive energy into making NFSv4.1 better rather than
> trying to reinvent NFS/RPC/XDR.
> 
> Although It's rather late in the process since the NFSv4 working group
> is close to putting the NFSv4.1 Internet-draft up for last
> call, we would certainly appreciate more implementation feedback.


I am more than happy to give feedback, though (as you say) it is 
probably too late for substantial feedback to have any large effect.

My general engineering opinions of pNFS:

* Fills an obvious need:  eliminating the need to copy data through the 
metadata interface to backend storage.  Many clear, tangible benefits here.


* pNFS major issue #1:  client storage protocol

Storing and retrieving blobs over the network, with strong 
authentication/integrity/security, is a solved problem.

Pick ONE client storage protocol (HTTP? iSCSI OSD2?), and stick to it. 
Or maybe HTTP|SCSI but nothing more.  Heck, even BitTorrent w/ auth 
extensions would be better than yet another protocol for similar 
purposes (not that I'm advocating BT, just saying...).

Maximize reuse of existing software and mindshare.


* pNFS major issue #2:  abandons NFS's "one true generic" path

I believe pNFS violates the "spirit of NFS" by deviating from a defacto 
assumption found in earlier versions:  data transfer is simple, 
arbitrary blobs, addressed in the same manner, and sent via the same 
protocol.

Pick ONE layout type, and stick to it.  Banish all other layout types to 
other software layers.

Protocol conversion servers, firmware, and other softwares can easily 
convert from a generic layout to something more exotic like OSD or 
[insert site specific protocol here].

NFS itself should not be delving into low-level storage details like 
this.  Clients should not need to know low-level details (like stripe 
sizes).  In Linux, we call this a layering violation.

Working on kernel storage drivers as I do, I can see the attraction of 
wanting to do things this way...  but we invented layering and 
abstraction in computer science for good reasons :)


* pNFS major issue #3: no longer a "closed loop" protocol

By permitting multiple layout types, and in particular undefined 
(site-specific) layout types, it is by definition _impossible_ for 
anyone to claim full protocol interoperability with other implementations.

The number of possible combinations approaches infinity, with obvious 
consequences on testing, and production software quality.

And when a marketing department advertises "fully NFSv4.1 compliant!" on 
ther company's appliance, it is trivial for any engineer to construct 
another "fully NFSv4.1 compliant" setup -- with equivalent 
authentication, metadata and data sets -- that is not interoperable 
except via the fallback case (copy through the metadata server).

Such interoperability breakdowns are IMO not in the spirit of NFS.

	Jeff
