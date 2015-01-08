Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:48487 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbbAHSNw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 13:13:52 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so3563829qcz.5
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 10:13:52 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH v3 00/49] *** Add Flexfile Layout Module ***
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <54AEA04F.8090300@Netapp.com>
Date: Thu, 8 Jan 2015 10:13:48 -0800
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <CC75FB75-C9A9-4717-8395-B6F9A7792CDC@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <20150108144559.GA11530@infradead.org> <54AEA04F.8090300@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 8, 2015, at 7:20 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> On 01/08/2015 09:45 AM, Christoph Hellwig wrote:
>> Do you also have a git tree available?  I'd like to test that the
>> core pnfs changes don't cause regressions for the block layout driver.
>> 
>> Talking about testing, where can I get the flexfiles server to test this
>> layout?
> 
> How much testing has been done on these patches?  Make sure you're at least running xfstests (and probably nfsometer)!
> 
> Anna



This has been under internal QA testing for months.