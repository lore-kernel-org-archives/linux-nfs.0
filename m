From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "NFS: readdir reply truncated!" messages
Date: 17 Jul 2003 01:29:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslluykq3s.fsf@charged.uio.no>
References: <OFB8B66654.D2A7A332-ON85256D64.00769E59-86256D64.007727EB@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cviQ-00057R-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 16:29:42 -0700
To: "Robert Williamson" <robbiew@us.ibm.com>
In-Reply-To: <OFB8B66654.D2A7A332-ON85256D64.00769E59-86256D64.007727EB@pok.ibm.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Robert Williamson <robbiew@us.ibm.com> writes:

     > I'm these seeing messages occaisionally using 'dmesg' on both
     > of my test clients.  What exactly does this mean? Is the packet
     > size being truncated?

It means that the packet sent by the server caused the client to
overrun because the end-marker was not found (i.e. the client found
itself attempting to read beyond the end of the packet).

Two possibilities:
  - The server is failing to set the end-marker.
  - The server is sending a packet that exceeds the 4k buffer
    advertised by the client, and so the packet is truncated before we
    reach the end-marker.

This is a non-fatal error, since the client should have no problems
recovering (it detect the overrun, and inserts its own end-marker)
however we still send out a warning message.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
