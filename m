From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: NFS Performance Between SGI Servers and Linux Clients
Date: Fri, 23 May 2003 13:11:56 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ECE100C.6060409@cinesite.co.uk>
References: <482A3FA0050D21419C269D13989C6113127DEB@lavender-fe.eng.netapp.com> <16077.19956.958830.569577@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
        Iain Irwin-Powell <iain@cinesite.co.uk>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JBPU-0001TT-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 05:12:32 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16077.19956.958830.569577@charged.uio.no>
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

Trond Myklebust wrote:

>>>>>>" " == Charles Lever <Lever> writes:
>>>>>>            
>>>>>>
>
>     > trond, isn't there a read ahead value in the client that can be
>     > tweaked?  he could trim down vm_max_readahead, unless there is
>     > a max_readahead[] entry for anonymous file systems.
>
>That should partly help to trim it down unless the client is reading
>from > 1 file at a time. In that case the RPC layer will still try to
>issue more reads (up to MIN(16,vm_max_readahead) requests per process)
>if the network and server permits it.
>
>Beware, though, that vm_max_readahead will effect not only
>NFS. Performance on other tasks may suffer.
>  
>
I will give this a try in Iain's absence. In the real world we *are* likely
to be reading multiple files, however for testing purposes we don't have to.

Danny

-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
