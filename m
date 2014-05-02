Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5-phx2.redhat.com ([209.132.183.37]:39816 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbaEBXbp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2014 19:31:45 -0400
Date: Fri, 2 May 2014 18:34:20 -0400 (EDT)
From: Doug Ledford <dledford@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
        Allen Andrews <allen.andrews@emulex.com>
Message-ID: <5172727.2501.1399070062785.JavaMail."Doug Ledford"@Phenom>
In-Reply-To: <45067B04-660C-4971-B12F-AEC9F7D32785@oracle.com>
References: <20140430191433.5663.16217.stgit@manet.1015granger.net> <5363f223.e39f420a.4af6.6fc9SMTPIN_ADDED_BROKEN@mx.google.com> <45067B04-660C-4971-B12F-AEC9F7D32785@oracle.com>
Subject: Re: [PATCH V3 00/17] NFS/RDMA client-side patches
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> 
> On May 2, 2014, at 3:27 PM, Doug Ledford <dledford@redhat.com> wrote:
> 
> > I tested nfsv3 in both IB and RoCE modes with rsize=32768 and
> > wsize=32768 -> not DOA, reliable, did data verification and passed
> > 
> > I tested nfsv3 in both IB and RoCE modes with rsize=65536 and
> > wsize=65536 -> not DOA, but not reliable either, data transfers
> > will stop after a certain amount has been transferred and the
> > mount will have a soft hang
> 
> Can you clarify what you mean by “soft hang?” Are you seeing a
> problem when mounting with the “soft” mount option, or does this
> mean “CPU soft lockup?” (INFO: task hung for 120 seconds)

Neither of those options actually.  I'm using hard,intr on the mount
flags, and by soft hang I mean that the application copying data
will come to a stop and never make any progress again.  When that
happens, you can usually interrupt the process and get back to the
command line, but it doesn't clean up internally in the kernel
because from that point on, attempts to unmount the nfs filesystem
return EBUSY.


> > ToDo items that I see:
> > 
> > Write NFSv4 rdma protocol mount support
> 
> NFSv4 does not use the MNT protocol. If NFSv4 is not working for you,
> there’s something else going on. For me NFSv4 works as well as NFSv3.
> Let me know if you need help troubleshooting.

OK, I'll see if I'm doing something wrong.  I can do nfs4 tcp mounts
just fine, but trying to do nfs4 rdma mounts results in operation not
permitted returns on the client.  And nfs3 mounts using rdma work as
expected.  This is all with the same server, same client, same mount
point, etc.

> > Fix client soft mount hangs when rsize/wsize > 32768
> 
> Does that problem occur with unpatched v3.15-rc3 on the client?

Probably.  I've been able to reproduce this for a while.  I originally
thought it was a problem between Mellanox <-> QLogic/Intel operation
because it reproduces faster in that environment, but I can get it to
reproduce in Mellanox <-> Mellanox situations too.

> HCAs/RNICs that support MTHCAFMR and FRMR should be working up to the
> largest rsize and wsize supported by the client and server.
> 
> When I use ALLPHYSICAL with large wsize, typically the server starts
> dropping NFS WRITE requests. The client retries them forever, and
> that
> looks like a mount point hang.
> 
> Something like https://bugzilla.linux-nfs.org/show_bug.cgi?id=248

This sounds like what I'm seeing here too.

> > Fix DOA of ocrdma driver
> 
> Does that problem occur with unpatched v3.15-rc3 on the client?

Haven't tried.  I'll queue that up for next week.

> Emulex has reported some problems when reconnecting, but
> I haven’t heard of issues that occur right at mount time.
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD
	      http://people.redhat.com/dledford

