Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:51427 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574AbaFXRHz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 13:07:55 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v1 00/13] NFS/RDMA patches for 3.17
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAJZOPZ+ix6tPDHXbVrSnVzofHSbzqOoyTBvzkEo-GJpOYOaPFA@mail.gmail.com>
Date: Tue, 24 Jun 2014 13:07:50 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A922572E-627F-4283-9CC9-2D4D47AF619F@oracle.com>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net> <CAJZOPZ+ix6tPDHXbVrSnVzofHSbzqOoyTBvzkEo-GJpOYOaPFA@mail.gmail.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 24, 2014, at 10:35 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:

> On Tue, Jun 24, 2014 at 1:39 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> The main purpose of this series is to address more connection drop
>> recovery issues by fixing FRMR re-use to make it less likely the
>> client will drop the connection due to a memory operation error.
>> 
>> Some other clean-ups and fixes are present as well.
> 
> 
> From quick looking, patches 1,2 and 5 of series and maybe more have
> very good match for 3.16-rc (fix kernel crashes etc), I don't think
> they need to wait for 3.17

My take:

1/13 fixes a panic that should never be hit (that used to be a BUG,
which never fired in operation).

2/13 might be a candidate for 3.16-rc. It’s up to Trond.

5/13 doesn’t fix a regression, it always worked that way.

I’ve updated the “Fixes:” tag in these, will appear in v2 of the series.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



