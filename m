From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Sun, 27 Oct 2002 20:10:00 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021027.201000.112627104.taka@valinux.co.jp>
References: <200210221616.23282.habanero@us.ibm.com>
	<20021023.182925.15272672.taka@valinux.co.jp>
	<00a201c27b72$83ab8760$2a060e09@beavis>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185lQS-0007tp-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Oct 2002 03:17:48 -0800
To: habanero@us.ibm.com
In-Reply-To: <00a201c27b72$83ab8760$2a060e09@beavis>
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

Hi,

>> Can You check /proc/net/rpc/nfsd which shows how many NFS requests have
>> been retransmitted ?

You can also check the client side.
/proc/net/rpc/nfs
net 0 0 0 0
rpc 191035 4339 0
           ^^^^
This field shows us how many times the client has retransmitted RPC requests.

Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
