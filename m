From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: performance question
Date: 01 Apr 2003 07:40:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsllyuzsfo.fsf@charged.uio.no>
References: <20030331213739.25218.qmail@pour.midcoast.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190EVh-0007tE-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 21:40:37 -0800
To: jp@pour.midcoast.com
In-Reply-To: <20030331213739.25218.qmail@pour.midcoast.com>
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

>>>>> " " == jp  <jp@pour.midcoast.com> writes:

     > Server (coffeepot) - Athlon XP2000, Suse 8.1, 2.4.21-pre6
     > kernel from kernel.org, boots to an ata100 drive, promise
     > rm8000 external hardware raid5 array on adaptec Adaptec
     > AHA-2940U/UW/D controller, 3com 3c905C forced to 100-FD with
     > "/sbin/mii-tool -F 100baseTx-FD eth1".

Why do you have to force it to 100-FD?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
