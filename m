From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Wed, 09 Aug 2006 18:41:09 -0400
Message-ID: <1155163270.15624.66.camel@localhost>
References: <44DA25D3.3010003@redhat.com>
	<1155159937.15624.22.camel@localhost>  <44DA5CBF.3040309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAwjq-000127-GW
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 15:41:22 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GAwjo-0006X2-Hy
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 15:41:23 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <44DA5CBF.3040309@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-08-09 at 18:07 -0400, Wendy Cheng wrote:

> 
> Disagree ! :)
> 
> The whole thing is about deadlock, not about reference count. Look at 
> the logic ... nlm_traverse_files grabs the nlm_file_mutex, then comes 
> down to nlm_release_file where it tries to get nlm_file_mutex lock 
> again. I'll need to run now - we can discuss this tomorrow morning. 
> Please re-read the issue and we'll discuss later.

OK. The we need to fix the borken mark/sweep crap. Trying to circumvent
refcounting rules is unacceptable.

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
