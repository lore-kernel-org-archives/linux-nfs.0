From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Re: Problems with statd and lockd
Date: Sat, 5 Apr 2003 13:18:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030405131821.595ca734.philippe.gramoulle@mmania.com>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
	<shsadf5s12f.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pgramoul.net2.nerim.net ([80.65.227.234] helo=philou.aspic.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191lh6-0002C6-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 03:18:44 -0800
Received: from philou.gramoulle.local (philou.gramoulle.local [192.168.254.2])
	by philou.aspic.com (Postfix) with SMTP id 186A019B
	for <nfs@lists.sourceforge.net>; Sat,  5 Apr 2003 13:18:22 +0200 (CEST)
To: NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <shsadf5s12f.fsf@charged.uio.no>
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


On 05 Apr 2003 12:14:48 +0200
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

  | >>>>> " " == Philippe Gramoull <Philippe> writes:
  | 
  |      > We have filesystems that are exported sync, other are exported
  |      > async.
  | 
  |      > Can you tell me what the "-5" return code means ?
  | 
  | -5 == -EIO. For a soft RPC call it usually means that a timeout has
  | occured. This would be consistent with the logged 'localhost not
  | responding'.

Ok.

And do you have an idea of what could cause such errors ?

We've been  using Linux NFS servers and clients for a long time and never had problems like this before.

Latest kernel before this one was a 2.4.19-pre6 ( servers & clients )
Now clients & servers are 2.4.21-pre5.

Thanks

Philippe


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
