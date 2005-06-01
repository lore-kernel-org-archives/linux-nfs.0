From: Neil Horman <nhorman@redhat.com>
Subject: Re: How to detect using whether NFS server is down or not
Date: Wed, 1 Jun 2005 07:28:58 -0400
Message-ID: <20050601112858.GE24276@hmsendeavour.rdu.redhat.com>
References: <b0c71d02050531055138f6b435@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdRPT-0002OY-7M
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 04:29:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DdRPR-0008Kg-Nl
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 04:29:19 -0700
To: Kapil Dhakad <dhakad@gmail.com>
In-Reply-To: <b0c71d02050531055138f6b435@mail.gmail.com>
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

On Tue, May 31, 2005 at 06:21:02PM +0530, Kapil Dhakad wrote:
> Hello,
> 
> I am using WebNFS SDK client provided by sun, with NFS server.
> I implemented this client-server architecture in web application,
> my web application create some document on the fly and store
> it on different server.
> 
> I am facing problem, suppose NFS server is down. At that time
> WebNFS client continuously make requrest to server and goes into
> infinite. How to avoid this problem ?
> Is there any way using "JAVA" to detect whether server is down or not ?
> What will be solution over it ?
> 
> Please reply urgently
> 
> Thanks
> - Kapil Dhakad

you can use rpcinfo -u as an rpc ping mechanism to see if the apprpriate
services are still active on the remote host, but doing so won't avoid
occasional hangs on your file system.
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
