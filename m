From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can't contact portmapper - connection refused.
Date: 10 Jun 2003 19:35:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuftq1io.fsf@charged.uio.no>
References: <9A0276ECD63AD4118D1300E018C2F89418C258@HAL01>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Pn5O-0004jY-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Jun 2003 10:39:07 -0700
To: Myra Hager <myra.hager@halsystems.com>
In-Reply-To: <9A0276ECD63AD4118D1300E018C2F89418C258@HAL01>
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

>>>>> " " =3D=3D Myra Hager <myra.hager@halsystems.com> writes:

     > Can someone please tell me what I seem to be missing here?=A0

You have probably set up port filtering (ipchains or iptables) to
filter the reserved ports that NFS is using.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
