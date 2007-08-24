From: Zoot <z00t@gmx.net>
Subject: Re: umount fails with device busy
Date: Fri, 24 Aug 2007 20:52:45 +0200
Message-ID: <20070824185245.GA3583@localhost>
References: <20070823184544.237460@gmx.net> <46CDE805.4090909@oracle.com>
	<20070823201414.GB4692@localhost> <46CDEEF2.8040309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOeH9-0005wO-TL
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 11:52:56 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IOeHC-0002gL-Mq
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 11:53:00 -0700
In-Reply-To: <46CDEEF2.8040309@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 23, 2007 at 04:32:50PM -0400, Chuck Lever wrote:
> Zoot wrote:
> >>This is normal and expected behavior.  One problem may be that your 
> >>server is slow, and thus there are RPCs left outstanding for a bit on 
> >>your client after your application exits.  The COMMIT calls from that 
> >>trace suggest that there is dirty data the client is writing back to the 
> >>server.
> >But I had expected that umount blocks until the commit calls are
> > finished as it is with local file systems?
> 
> Sorry, it doesn't.  It has no way of knowing how long those RPCs will take.
> 
> There is a "lazy unmount" facility that removes the NFS share from your 
> client's name space and handles the outstanding RPCs in the background. 
>  I'm not sure if it's working, but you could try "umount -l".
What's with sync() would it wait for the nfs commits? 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
