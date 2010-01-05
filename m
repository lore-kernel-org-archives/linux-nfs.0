From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: rpcbind doesn't build on Fedora 12 ?
Date: Tue, 5 Jan 2010 13:58:16 -0500
Message-ID: <158159AE-BD50-4D41-9B14-450241B42E23@oracle.com>
References: <268D6516-A19A-4CC7-BF03-6FBFA7C79D0B@oracle.com> <4B43887D.2000006@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:33878 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab0AES7q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2010 13:59:46 -0500
In-Reply-To: <4B43887D.2000006-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 5, 2010, at 1:44 PM, Steve Dickson wrote:
> On 01/05/2010 12:12 PM, Chuck Lever wrote:
>> security.c:24:27: error: rpcsvc/rquota.h: No such file or directory
>> security.c: In function =91check_callit=92:
>> security.c:286: error: =91RQUOTAPROG=92 undeclared (first use in thi=
s =20
>> function)
>> security.c:286: error: (Each undeclared identifier is reported only =
=20
>> once
>> security.c:286: error: for each function it appears in.)
>>
>> I have libtirpc-devel installed, but a "find" on /usr/include turns =
=20
>> up
>> no file named rquota.h.  Am I missing some other package?
>>
> Yeah... 'yum install quota-devel' is your friend...

That fixes it, but... I never had to install this package before.  =20
Either it's new with Fedora 12, or the Fedora 12 install with =20
"software development" checked doesn't install this one any more.

Is there a good reason why an RPC header would be separated into a non-=
=20
obvious package like this?

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




