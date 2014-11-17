Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:29796 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbaKQVCc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 16:02:32 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: mount default minor version behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.LRH.2.11.1411171443500.21288@sh-el6.eng.rdu2.redhat.com>
Date: Mon, 17 Nov 2014 16:02:25 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DC5B273D-1594-45A4-A490-886A48CD4849@oracle.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <3987E905-52A4-4F8E-AF97-FCAC0503260F@oracle.com> <alpine.LRH.2.11.1411171443500.21288@sh-el6.eng.rdu2.redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 17, 2014, at 2:47 PM, Benjamin Coddington <bcodding@redhat.com> wrote:

> 
> On Tue, 11 Nov 2014, Chuck Lever wrote:
> 
>> 
>>> On Nov 11, 2014, at 8:39 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
>>> 
>>> I will update mount.nfs so the default version is 4.1.
>> 
>> Hi Ben, can you explicitly test your change with NFSv4.0-only servers? Thanks!
> 
> Hi Chuck,
> 
> I've posted a first-pass:
> http://marc.info/?l=linux-nfs&m=141625339013956&w=2
> 
> I've tested against rpc.nfsd with '-N 4.1', and fallback to v4.0 seems
> to work fine.

Thanks!

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



