From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Re: Problems with statd and lockd
Date: Sat, 5 Apr 2003 14:05:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030405140532.2ce1873e.philippe.gramoulle@mmania.com>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
	<shsadf5s12f.fsf@charged.uio.no>
	<20030405131821.595ca734.philippe.gramoulle@mmania.com>
	<shsistt5fju.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pgramoul.net2.nerim.net ([80.65.227.234] helo=philou.aspic.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191mQh-000348-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 04:05:51 -0800
Received: from philou.gramoulle.local (philou.gramoulle.local [192.168.254.2])
	by philou.aspic.com (Postfix) with SMTP id 59A1F1717
	for <nfs@lists.sourceforge.net>; Sat,  5 Apr 2003 14:05:32 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <shsistt5fju.fsf@charged.uio.no>
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


On 05 Apr 2003 13:50:29 +0200
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

  | The message just means what it says. The problem could be anything
  | from a temporary hang of statd or the portmapper right down to a deep
  | kernel bug.
  |   Trond

Ok,

Portmapper was up. It was statd that was down and lockd , but they had been started
correctly before the problem happened.

I'll try to reproduce the problem as it happened of 4 different NFS servers.

I'll turn RPC debugging on and see if i can get something interesting.

Thanks,

Philippe



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
