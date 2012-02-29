Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47037 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965072Ab2B2XRd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 18:17:33 -0500
Date: Wed, 29 Feb 2012 18:17:32 -0500
To: Orion Poplawski <orion@cora.nwra.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4 mount hanging suddenly
Message-ID: <20120229231732.GD6506@fieldses.org>
References: <4F4EA6D0.30606@cora.nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4EA6D0.30606@cora.nwra.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 29, 2012 at 03:29:36PM -0700, Orion Poplawski wrote:
> Just starting today, one of our user's nfs mounted home directory
> has started locking up.  Client is Fedora 16 32-bit, server is
> CentOS 5.7 32-bit.  Have not seen this particular problem elsewhere
> (yet).
> 
> I captured this trace on the server after the hang:
> 
> http://sw.cora.nwra.com/tmp/marie-nfs-home-lwang-hang.pcap
> 
>   1   0.000000  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;GETATTR GETATTR
>   2   0.000133   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 1) <EMPTY> PUTFH;GETATTR GETATTR
>   3   0.000421  10.10.20.15 -> 10.10.10.1   TCP 879 > nfs [ACK]
> Seq=137 Ack=225 Win=17738 Len=0 TSV=3584653 TSER=2438333196
>   4   0.000519  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;ACCESS ACCESS;GETATTR GETATTR
>   5   0.000587   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 4) <EMPTY> PUTFH;ACCESS ACCESS;GETATTR GETATTR[Unreassembled
> Packet [incorrect TCP checksum]]
>   6   0.040522  10.10.20.15 -> 10.10.10.1   TCP 879 > nfs [ACK]
> Seq=289 Ack=465 Win=17738 Len=0 TSV=3584694 TSER=2438333196
>   7   0.451636  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;SAVEFH SAVEFH;OPEN OPEN;DELEGRETURN DELEGRETURN;Unknown

That looks weird.  Looking at the pcap--ok, the "delegreturn" is a
mistake, there's no delegreturn there.

>   8   0.451892   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 7) <EMPTY> PUTFH;SAVEFH SAVEFH;OPEN OPEN(10008)

That probably means the server is waiting for the client to return a
delegation.

Either the server's confused about their being a delegation, or the
client's failing to return one it should?

--b.

>   9   0.452164  10.10.20.15 -> 10.10.10.1   TCP 879 > nfs [ACK]
> Seq=529 Ack=529 Win=17738 Len=0 TSV=3585105 TSER=2438333648
> .....
> 120  53.161949  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;GETATTR GETATTR
> 121  53.162281   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 120) <EMPTY> PUTFH;GETATTR GETATTR
> 122  53.162596  10.10.20.15 -> 10.10.10.1   TCP 879 > nfs [ACK]
> Seq=8205 Ack=10341 Win=17738 Len=0 TSV=3637816 TSER=2438386366
> 123  53.162680  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;GETATTR GETATTR
> 124  53.162748   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 123) <EMPTY> PUTFH;GETATTR GETATTR[Unreassembled Packet
> [incorrect TCP checksum]]
> 125  53.163245  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;GETATTR GETATTR
> 126  53.163418   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 125) <EMPTY> PUTFH;GETATTR GETATTR
> 127  53.203530  10.10.20.15 -> 10.10.10.1   TCP 879 > nfs [ACK]
> Seq=8493 Ack=10685 Win=17738 Len=0 TSV=3637857 TSER=2438386368
> 128  53.450308  10.10.20.15 -> 10.10.10.1   NFS V4 COMP Call <EMPTY>
> PUTFH;ACCESS ACCESS;GETATTR GETATTR
> 129  53.450457   10.10.10.1 -> 10.10.20.15  NFS V4 COMP Reply (Call
> In 128) <EMPTY> PUTFH;ACCESS ACCESS;GETATTR GETATTR[Unreassembled
> Packet [incorrect TCP checksum]]
> 130  53.450671  10.10.20.15 -> 10.10.10.1   TCP 879 > nfs [ACK]
> Seq=8645 Ack=10925 Win=17738 Len=0 TSV=3638104 TSER=2438386655
> 
> 
> I was not able to find any error messages anywhere.  Server has been
> up 28 days.  Client was up for 14 days before first hang, then 2
> more today.  Home directories are automounted and I was able to
> access a different home directory that is served off the save server
> and filesystem.
> 
> client kernels: 3.2.3-2.fc16.i68, 3.2.7-1.fc16.i68
> server kernel: 2.6.18-274.17.1.el5
> 
> earth:/export/home/lwang on /home/lwang type nfs4 (rw,noatime,vers=4,rsize=32768,wsize=32768,namlen=255,acregmin=1,acregmax=1,acdirmin=1,acdirmax=1,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.10.20.15,minorversion=0,local_lock=none,addr=10.10.10.1)
> 
> There is a newer nfs-utils:
> Jan 24 03:34:43 Updated: 1:nfs-utils-1.2.5-4.fc16.i686
> 
> may try backing that off, but doesn't seem like a big change:
> 
> * Mon Jan 16 2012 Steve Dickson <steved@redhat.com> 1.2.5-4
> - Reworked how the nfsd service requires the rpcbind service (bz 768550)
> 
> and seems to only affect nfs-server.
> 
> Anything else to check?
> 
> TIA,
> 
>  Orion
> 
> -- 
> Orion Poplawski
> Technical Manager                     303-415-9701 x222
> NWRA, Boulder Office                  FAX: 303-415-9702
> 3380 Mitchell Lane                  orion@cora.nwra.com
> Boulder, CO 80301              http://www.cora.nwra.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
