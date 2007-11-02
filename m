From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Need more threads?
Date: Fri, 02 Nov 2007 07:38:55 -0400
Message-ID: <EXNANE01GA7zyWR4Atg00000876@exnane01.hq.netapp.com>
References: <200711011800.08010.huangxiong@uit.com.cn>
	<EXNANE01YewQ1N8Pik30000086b@exnane01.hq.netapp.com>
	<200711021128.07881.huangxiong@uit.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: Huang Xiong <huangxiong@uit.com.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inutj-0006kv-C5
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 04:41:11 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inuto-0003pO-Rq
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 04:41:17 -0700
In-Reply-To: <200711021128.07881.huangxiong@uit.com.cn>
References: <200711011800.08010.huangxiong@uit.com.cn>
	<EXNANE01YewQ1N8Pik30000086b@exnane01.hq.netapp.com>
	<200711021128.07881.huangxiong@uit.com.cn>
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

At 11:28 PM 11/1/2007, Huang Xiong wrote:
>Tom,
>
>I worry about the NFS performance as I have to runing only one nfsd thread.
>As you see in the previous letter, I do not understan "th" very clearly to =

>judge the current thread is sufficient or have been in heavy load.

Ah. Well, it's clear that you do need more, but with only one it's hard to
say how many more. Normally people run at least 4 to 8, and many more
on some servers. (Actually, many commercial servers don't have threads
at all, they achieve much higher IOPS as a result).

If you are able run more threads, then post your "th" stats again and we
can give better advice. This is a very complex area however, dependent
on many, many factors. What problem are you trying to solve by limiting
the server threads so severely?

Tom.

>
>Thanks.
>P.H.
>
>
>
>
>=D4=DA =D0=C7=C6=DA=CB=C4 01 =CA=AE=D2=BB=D4=C2 2007 22:55=A3=ACTalpey, Th=
omas =D0=B4=B5=C0=A3=BA
>> To clarify - you're intentionally running with only one nfsd thread,
>> but you want to know if you need more? The answer is you almost
>> always need multiple nfsd threads, but if you describe your "special
>> situation" maybe we can offer more advice.
>>
>> The "th" line gives you statistics on the relative use of multiple nfsd
>> threads. It's a histogram of the number of running nfsd's versus the
>> available pool. However, since your pool is only one thread (the first
>> number on the line), the histogram itself isn't very useful. What
>> information are you looking for?
>>
>> Tom.
>>
>> At 06:00 AM 11/1/2007, Huang Xiong wrote:
>> >Hello all,
>> >
>> >I have to only open one nfsd thread in this special situation.
>> >
>> >I do not understand the "th" line very clearly, and I find various
>> > comments in the net . Please help me see the below two NFS server, do
>> > them need more threads? and would you evaluate it for me?
>> >
>> >Thanks in advance.
>> >Phillip
>> >
>> >--------------------------------------------------------
>> >[root@node1 ~]# cat /proc/net/rpc/nfsd
>> >rc 0 0 317
>> >fh 0 0 0 0 0
>> >io 0 0
>> >th 1 17 130.092 54.005 52.006 0.000 5.599 78.743 89.426 197.553 0.000
>> > 11.259 ra 2 0 0 0 0 0 0 0 0 0 0 0
>> >net 317 83 230 81
>> >rpc 317 0 0 0 0
>> >proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>> >proc3 22 5 113 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 87 110 0 0
>> >proc4 2 0 0
>> >
>> >
>> >[root@node2 ~]# cat /proc/net/rpc/nfsd
>> >rc 0 0 550
>> >fh 0 0 0 0 0
>> >io 0 0
>> >th 1 137 80.840 5.479 0.000 0.000 0.000 0.000 0.000 0.000 0.000 50.640
>> >ra 2 0 0 0 0 0 0 0 0 0 0 0
>> >net 550 216 330 113
>> >rpc 550 0 0 0 0
>> >proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>> >proc3 22 3 181 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 186 178 0 0
>> >
>> >
>> >
>> >-----------------------------------------------------------------------=
--
>> >This SF.net email is sponsored by: Splunk Inc.
>> >Still grepping through log files to find problems?  Stop.
>> >Now Search log events and configuration files using AJAX and a browser.
>> >Download your FREE copy of Splunk now >> http://get.splunk.com/
>> >_______________________________________________
>> >NFS maillist  -  NFS@lists.sourceforge.net
>> >https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
