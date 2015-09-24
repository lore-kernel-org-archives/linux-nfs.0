Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35848 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756169AbbIXFsQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 01:48:16 -0400
Date: Thu, 24 Sep 2015 07:48:08 +0200
From: Alexander Aring <alex.aring@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
Message-ID: <20150924054806.GA1702@omega>
References: <20150923102953.GA8918@omega>
 <5602809D.2020500@cumulusnetworks.com>
 <20150923115757.GA23260@omega>
 <20150923122714.GA31569@omega>
 <CAHQdGtSuhAVMWqm__UYvuKCrAGW54KO10XTWoju0Singq1SbqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHQdGtSuhAVMWqm__UYvuKCrAGW54KO10XTWoju0Singq1SbqQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Wed, Sep 23, 2015 at 09:16:00AM -0400, Trond Myklebust wrote:
...
> 
> Is that happening when the transport is being torn down? If so, is it
> fixed by http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=79234c3db6842a3de03817211d891e0c2878f756
> ?

thanks. This patch fixed my issue.

- Alex
