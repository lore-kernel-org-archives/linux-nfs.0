From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Poor Fedora Core 1's NFS performance and how to tune it?
Date: Mon, 19 Apr 2004 10:16:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4083DF2A.3000405@RedHat.com>
References: <41089CB27BD8D24E8385C8003EDAF7AB08485A@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, ops <ops@alexa.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFZZN-0005Yo-HG
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 07:16:21 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BFZZN-0006K1-5l
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 07:16:21 -0700
To: Guolin Cheng <guolin@alexa.com>
In-Reply-To: <41089CB27BD8D24E8385C8003EDAF7AB08485A@karl.alexa.com>
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

Guolin Cheng wrote:

>Hi,
>
> We installed about tens of Fedora Core 1 machines, But then found that
>the FC1 NFS speed is greatly slow down contrasted with our previous
>Redhat 8.0.
>Our FC1's nfs speed is now at 6MB/s, while original Redhat 8.0's speed
>is at 10MB/s. For both operation systems I did no special NFS tunings
>  
>
Are you seeing any rpc/tcp transmits? nfsstat will show rpc retrans and
netstat will show tcp retrans... Also any type of messages being logged
to /var/log/messages?

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
