From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Utility to tune NFS parameters?
Date: Thu, 4 Oct 2007 10:31:52 -0400
Message-ID: <78EC3A4D-AC81-4A35-BD50-166C87707763@oracle.com>
References: <29A7C5F65D54744CBFD97CD62A33DEE90241DA6F@VFOHMLAO13.Enterprise.afmc.ds.af.mil>
	<48609735-2D9E-4E5E-A593-51D99C096BB7@oracle.com>
	<29A7C5F65D54744CBFD97CD62A33DEE90241DC19@VFOHMLAO13.Enterprise.afmc.ds.af.mil>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Maute, Kevin P CTR AFRL/RBOO" <Kevin.Maute@WPAFB.AF.MIL>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdRkh-0003CH-3H
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 07:32:35 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdRkk-0000EN-1A
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 07:32:40 -0700
In-Reply-To: <29A7C5F65D54744CBFD97CD62A33DEE90241DC19@VFOHMLAO13.Enterprise.afmc.ds.af.mil>
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

cc: nfs@lists.sourceforge.net, used for generic NFS issues;
removed nfsv4@linux-nfs.org, as it is for NFSv4 development.

On Oct 4, 2007, at 9:10 AM, Maute, Kevin P CTR AFRL/RBOO wrote:
> To give a little history, I have a compute cluster that was running
> RHEL4 and /home mounted as an NFS share.  Fairly standard and it  
> seemed
> to have the standard NFS response.  I upgraded the cluster to RHEL5  
> and
> all I/O is VERY sluggish.  Top is my standard day-to-day tool and it
> shows nothing.

Top will show you CPU hogs.  NFS is an I/O subsystem, so you won't  
get much information about it from top.  There is an "nfstop"  
floating around, but I don't know if it's in RHEL 5.

Anyway, upgrading to RHEL 5 is not supposed to cause a negative NFS  
performance change.  Consult the Linux NFS FAQ and How-To for advice  
on how to begin troubleshooting...

    http://nfs.sourceforge.net

>> -----Original Message-----
>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>> Sent: Wednesday, October 03, 2007 5:05 PM
>> To: Maute, Kevin P CTR AFRL/RBOO
>> Cc: nfsv4@linux-nfs.org
>> Subject: Re: Utility to tune NFS parameters?
>>
>> On Oct 3, 2007, at 4:24 PM, Maute, Kevin P CTR AFRL/VAOO wrote:
>>> I am looking for a utility that runs under RH Linux to test NFS
>>> throughput.  This is not the first time in my career that I have
>>> looked for such a beast but I am hoping for better results this
>>> time :)
>>
>> Kevin-
>>
>> You can use any file system performance tool for this.
>> Anything from
>> iozone to iometer.
>>
>> You might also test raw network throughput using iPerf or a similar
>> tool to get a baseline for comparing NFS read and write throughput.
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
