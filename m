From: David Myer <davidmyer800@yahoo.com>
Subject: nfs client question -- kernel version 2.4.18
Date: Mon, 19 May 2003 16:41:29 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030519234129.20427.qmail@web21008.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web21008.mail.yahoo.com ([216.136.227.62])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19HuG1-0003Fx-00
	for <nfs@lists.sourceforge.net>; Mon, 19 May 2003 16:41:29 -0700
To: nfs@lists.sourceforge.net
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

I am trying to understand nfs client code in 2.4.18.
Would appreciate the following advise.

1) in call_encode function (clnt.c), it initializes
the iov base and len for send and recv, why it is only
init iov[0] ? Does it mean it only use ONE IOV for
data send and receive ? If so, if I have use my own
type of buffer underneath, can I just copy it into
iov[0] ?

2) In nfs2xdr.c's nfs_xdr_readdirres function, when
nfs tries to get XDR data, it uses iov[1], I am not
sure when the header and payload got splitted into
iov[0] and iov[1]. I assume this happened ( in case of
udp), in data copy in udp_data_ready, but I did not
see this "split copy" happening.

3) In command line, I am trying to mount using tcp by
mount address1:/dir /address2:/mydir -o tcp
it returned 
nfs server reported service unavailable: Protocol not
available..

I saw on server side, when doing rpcinfo -p, mount
daemon does have tcp, what else special I need to
configure, on server or client side in order to mount
using tcp ?

Thanks much
Dave

__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
