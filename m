From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs performance problem
Date: Fri, 26 Oct 2007 10:18:29 -0400
Message-ID: <4721F735.8050503@oracle.com>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
	<20071025193457.GE4499@jakobus.spotify.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030500060600050402070704"
Cc: nfs@lists.sourceforge.net
To: Andreas Schuldei <andreas@schuldei.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlQ9m-00020v-Ox
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 07:27:26 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IlQ9q-00027R-Jl
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 07:27:32 -0700
In-Reply-To: <20071025193457.GE4499@jakobus.spotify.net>
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

This is a multi-part message in MIME format.
--------------030500060600050402070704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andreas Schuldei wrote:
> * Chuck Lever (chuck.lever@oracle.com) [071025 20:25]:
>> On Oct 25, 2007, at 9:10 AM, Andreas Schuldei wrote:
>> With a single client, you should not expect to get any better performance than by running the web service on the NFS 
>> > server.  The advantage of using NFS under a web service is that you can transparently scale horizontally.  When you add 
>> > a second or third web server that serves the same file set, you will see an effective increase in the size of the data 
>> > cache between your NFS server's disks and the web servers.
> 
> Not with terabyte of data and a distributed access pattern.
> Certainly i will have some cache hits but not enough to be able
> to serv considerable amounts out of RAM.

If you don't intend to scale horizontally by adding more clients, then 
inserting NFS between your disks and your web service is not recommended 
unless you have security requirement that needs to be solved by 
administering your data separate from running the web service.

>> If anything, the 10s 
>> latency you see when the web server is on the same system with the disks is indicative of local file system 
>> configuration issues.
> 
> how can i measure the latency on the local machine? i would be
> very interested in seeing how it behaves latency wise.

The iostat command has options for displaying disk service time.

>>> on the client i mount them like this:
>>>
>>> lotta:/var/disks/sda on /var/disks/sda type nfs (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44)
>>> lotta:/var/disks/sdb on /var/disks/sdb type nfs (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44)
>>> lotta:/var/disks/sdh on /var/disks/sdh type nfs (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44)
>>> lotta:/var/disks/sdi on /var/disks/sdi type nfs (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44)
>> There are some client-side mount options that might also help.  Using "nocto" and "actimeo=7200" could reduce 
>> synchonous NFS protocol overhead.  I also notice a significant amount of readdirplus traffic.  Readdirplus requests are 
>> fairly heavyweight, and in this scenario may be unneeded overhead.  Your client might support the recently added 
>> "nordirplus" mount option, which could be helpful.
>>
>> I wonder if "rsize=32k" is supported - you might want "rsize=32768" instead.
> 
> i think that gave an effect. now i am in the 90-100Mbyte/s
> ballpark and might hit the one-nic (1gbit) bottleneck.
> 
>> Or better, let the client and server 
>> negotiate the maximum that each supports automatically by leaving this option off.  You can check what options are in 
>> effect on each NFS mount point by looking in /proc/self/mountstats on the client.
> 
> there it says now, after i specified rsize=2097152:
>         opts:   rw,vers=3,rsize=1048576,wsize=1048576,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,intr,nolock,proto=tcp,timeo=600,retrans=2,sec=sys
> 
> i am surprised that it did not protest when it could not parse
> the "k". note that it it only took 1M chunks. how come?

1MB is the maximum that both your server and client support.  Again, if 
you don't specify rsize at all, the maximum both support will be 
negotiated automatically.

>> Insufficient read-ahead on your server may be an issue here.  Read traffic from the client often arrives at the server 
>> out of order, preventing the server from cleanly detecting sequential reads.  I believe there was a recent change to 
>> the NFS server that addresses this issue.
> 
> when did that go in? do i need to activate that somehow?

I don't think activation is needed.  Someone else on the list can speak 
to when it was included in recent kernels or in distributions.  However, 
since you are already close to your network limits, read-ahead is 
probably not an issue for you.

> how can i measure the latency on a loaded server? both locally
> and over nfs?

The iostat command, as mentioned above, will report on local disk 
activity.  NFS client activity has not been integrated into iostat, but 
there are some NFS client metrics available in /proc/self/mountstats.  I 
have a pair of Python tools that can extract and display RPC request 
latency information.  See:

   http://oss.oracle.com/~cel/linux-2.6/2.6.21/iostat-ms

and

   http://oss.oracle.com/~cel/linux-2.6/2.6.21/mountstats

--------------030500060600050402070704
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture, Linux Projects Group
email;internet:chuck.lever@oracle.com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------030500060600050402070704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------030500060600050402070704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030500060600050402070704--
