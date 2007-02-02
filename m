From: Peter Staubach <staubach@redhat.com>
Subject: Re: novice question about large write requests
Date: Fri, 02 Feb 2007 09:12:03 -0500
Message-ID: <45C346B3.4080109@redhat.com>
References: <4cf2912c0702020535i2b11691as8bc5ead997fa0d85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Venkatesh KS <venkatesh.ks@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCz9M-000575-H6
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 06:12:24 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCz9N-0005je-RW
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 06:12:26 -0800
In-Reply-To: <4cf2912c0702020535i2b11691as8bc5ead997fa0d85@mail.gmail.com>
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

Venkatesh KS wrote:
> Folks,
>
> I am trying to understand how nfs client handles a server reboot while 
> issuing multiple
> unstable writes followed by a commit.
>
> Say a user requests a large write requests.
> nfs client breaks it into multiple 32k requests, each 32k write 
> request being unstable
> and finally a commit call before the nfs client returns back to the user.
>
> If the server reboots in between these write calls, will the nfs 
> client know abt it.
> The write before this may not have made it to disk. If the nfs client 
> doenst know
> abt it then it goes ahead with commit call and returns.

I would suggest checking out RFC1813 for information on this topic.

       ps

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
