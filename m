From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with statd and lockd
Date: 05 Apr 2003 12:14:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadf5s12f.fsf@charged.uio.no>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191khM-0006m8-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 02:14:57 -0800
To: Philippe Gramoull~ <philippe.gramoulle@mmania.com>
In-Reply-To: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
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

>>>>> " " == Philippe Gramoull <Philippe> writes:

     > We have filesystems that are exported sync, other are exported
     > async.

     > Can you tell me what the "-5" return code means ?

-5 == -EIO. For a soft RPC call it usually means that a timeout has
occured. This would be consistent with the logged 'localhost not
responding'.

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
