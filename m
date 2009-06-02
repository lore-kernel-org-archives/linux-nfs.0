From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Tue, 2 Jun 2009 11:00:25 -0400
Message-ID: <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com> <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com> <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org> <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com> <1243615595.7155.48.camel@heimdal.trondhjem.org> <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com> <1243618500.7155.56.camel@heimdal.trondhjem.org> <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com> <1243686363.5209.16.camel@heimdal.trondhjem.org> <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Brian R Cowan <brcowan@us.ibm.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:34735 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbZFBPAu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jun 2009 11:00:50 -0400
In-Reply-To: <ac442c870905300602v6950ec42y5195d2d6ea7dd4c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 30, 2009, at 9:02 AM, Greg Banks wrote:
> On Sat, May 30, 2009 at 10:26 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
>> On Sat, 2009-05-30 at 10:22 +1000, Greg Banks wrote:
>>> On Sat, May 30, 2009 at 3:35 AM, Trond Myklebust
>>> <trond.myklebust@fys.uio.no> wrote:
>>>> On Fri, 2009-05-29 at 13:25 -0400, Brian R Cowan wrote:
>>>>>
>>>
>>
>> Firstly, the server only uses O_SYNC if you turn off write gathering
>> (a.k.a. the 'wdelay' option). The default behaviour for the Linux nfs
>> server is to always try write gathering and hence no O_SYNC.
>
> Well, write gathering is a total crock that AFAICS only helps
> single-file writes on NFSv2.  For today's workloads all it does is
> provide a hotspot on the two global variables that track writes in an
> attempt to gather them.  Back when I worked on a server product,
> no_wdelay was one of the standard options for new exports.

Really?  Even for NFSv3/4 FILE_SYNC?  I can understand that it  
wouldn't have any real effect on UNSTABLE.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
