From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nsm_mon_unmon: rpc failed, status=-13
Date: 07 May 2003 08:09:53 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuh3e18u.fsf@charged.uio.no>
References: <20030507033420.36115319.pau@eslack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DI7x-0008Ql-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 23:10:05 -0700
To: pof <pau@eslack.org>
In-Reply-To: <20030507033420.36115319.pau@eslack.org>
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

>>>>> " " == pau  <pof> writes:

     > I am having problems with nfs locking, this is the error that I
     > see in my logs, and I don't know what it means:

     > nsm_mon_unmon: rpc failed, status=-13 lockd: cannot monitor
     > 192.168.1.1 lockd: failed to monitor 192.168.1.1 nfs: server
     > 192.168.1.1 not responding, still trying nfs: server
     > 192.168.1.1 OK nsm_mon_unmon: rpc failed, status=-13 lockd:
     > cannot monitor 192.168.1.1 lockd: failed to monitor 192.168.1.1
     > nsm_mon_unmon: rpc failed, status=-13 [...]

Either you are firewalling the rpc.statd monitor, or the lockd
monitoring client is failing to use a port < 1024. The former you need
to fix yourself, however I do have a fix for the latter in my latest
NFS_ALL patch on

  http://www.fys.uio.no/~trondmy/src/2.4.21-rc1

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
