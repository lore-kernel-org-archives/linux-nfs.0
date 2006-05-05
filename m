From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Fri, 05 May 2006 10:59:30 -0400
Message-ID: <445B6852.5010509@redhat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com> <445834CB.4050408@citi.umich.edu> <445B5C2D.5040404@RedHat.com> <445B66E6.7030700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, cel@citi.umich.edu,
	nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fc1mR-0003MN-0x
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 07:59:43 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fc1mH-0008HE-Df
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 07:59:40 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <445B66E6.7030700@redhat.com>
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

Peter Staubach wrote:

>
> You can't just go to out_nowait here, can you?  What happens if something
> happened to the file while you were asleep?  Or an entry could be 
> added to


Opps, that would be "could not be added"...

> the cache for some reason such as kmalloc failure?  I would suggest going
> back to the top and starting the process all over again.


    Sorry...

       ps


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
