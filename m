From: "Shankar Anand" <shanand@novell.com>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Wed, 05 Jul 2006 00:19:02 -0600
Message-ID: <44ABA72E.AD69.00CC.0@novell.com>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
	<44AACDA6.AD69.00CC.0@novell.com>message from Shankar Anand on Tuesday
	July 4 <17579.22038.267510.116270@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, , nfs@lists.sourceforge.net,
	Kevin Coffman <kwc@citi.umich.edu>,
	J.BruceFields@sc8-sf-spam2.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fy0hc-0006Jx-6E
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 23:17:36 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fy0hc-00051M-5W
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 23:17:36 -0700
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <17579.22038.267510.116270@cse.unsw.edu.au>
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

Hi Neil,

>>> On 7/5/2006 at 11:33 AM,  Neil Brown <neilb@suse.de> wrote:
> On Tuesday July 4, shanand@novell.com wrote:
>> 
>> The patch attached here reads /proc/net/rpc/nfsd for nfsv4 server
>> statistics and displays them.
>> 
>> To maintain uniformity with older nfs versions operations 0 1 and 2
>> are also printed though they are not used by nfsv4.
> 
> Good..
> 
>> @@ -115,6 +126,7 @@ static statinfo		svcinfo[] = {
>>  	{ "proc2",      STRUCTSIZE(svcv2info),  svcv2info  },
>>  	{ "proc3",      STRUCTSIZE(svcv3info),  svcv3info  },
>>  	{ "proc4",      STRUCTSIZE(svcv4info),  svcv4info  },
>> +	{ "proc4ops",   STRUCTSIZE(svcv4opinfo),svcv4opinfo},
>>  	{ NULL,         0,                      NULL       }
>>  };
>>  
> 
> As it is called 'proc4ops', does that mean it will apply to all
> minor-versions, or do we expect a
> 	proc4.1ops
> 
> for NFSv4.1?  Or maybe proc4ops.1 ??
> 
> It doesn't really matter one way or the other, but I would like to
> know that the issue has been considered, and to know what the
current
> decision is.

Though the issue has not been discussed earlier on the mailing list,
my thought when I wrote the patch was that instead of creating 
new lines for each minor version (which may lead to confusion), 
we can add the additional procedures, if at all, to the same line. 

Anyway the server is going to have either nfs4 or nfs4.1 running at
one point in time. So it should be fine.

> (Meanwhile, The current patch is in .git waiting for the 1.0.9
> release).

Thanks.

Shankar

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
