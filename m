From: George Garvey <tmwg-nfs@inxservices.com>
Subject: Re: NFS Performance with sync or async
Date: Sat, 28 May 2005 05:53:43 -0700
Message-ID: <20050528125343.GY4944@inxservices.com>
References: <482A3FA0050D21419C269D13989C611308539BBA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dc0pM-0001bh-LJ
	for nfs@lists.sourceforge.net; Sat, 28 May 2005 05:54:08 -0700
Received: from [63.193.79.19] (helo=mwg.inxservices.lan)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dc0pK-0001g9-6j
	for nfs@lists.sourceforge.net; Sat, 28 May 2005 05:54:08 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C611308539BBA@lavender-fe.eng.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, May 27, 2005 at 07:45:12PM -0700, Lever, Charles wrote:
> to clarify, you are using the "sync" mount option on your NFS clients?
   Yes.
> why did you initially decide to use "sync"?
   Reading urgings from some of the NFS authors ...
   Also, for a while we were using an app that had a shared data base
base on NFS store. Async concerned me in that scenario. That has also
ended.
> 
> without knowing more details about your situation, let me suggest you
> might find something useful in the Linux NFS FAQ:
> 
>   http://nfs.sourceforge.net/
   I don't understand. I've resolved the situation, as I said.
   But I still don't understand why the sync option caused such a
dramatic slowdown. The actual part of the program that does the
writing went from several minutes to three seconds. If more details
or investigation are required to answer that question, I'd love to
know what they are so they can be provided.


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
