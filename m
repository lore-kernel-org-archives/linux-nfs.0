Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:40258 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbaCFPdK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 10:33:10 -0500
Received: by mail-ie0-f175.google.com with SMTP id to1so2849187ieb.34
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 07:33:09 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <04BE61B0-08B5-4E0C-88B6-6D93127BB64E@oracle.com>
Date: Thu, 6 Mar 2014 10:33:06 -0500
Cc: Andrew Martin <amartin@xes-inc.com>, Jim Rees <rees@umich.edu>,
        Brown Neil <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5B1102FE-8521-4BEF-8A2B-CE17EC32777F@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306123438.GA21799@umich.edu> <04BE61B0-08B5-4E0C-88B6-6D93127BB64E@oracle.com>
To: Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 10:26, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Mar 6, 2014, at 7:34 AM, Jim Rees <rees@umich.edu> wrote:
> 
>> Given this is apache, I think if I were doing this I'd use ro,soft,intr,tcp
>> and not try to write anything to nfs.
> 
> I agree. A static web page workload should be read-mostly or read-only. The (small) corruption risk with “ro,soft" is that an interrupted read would cause the client to cache incomplete data.

What? How? If that were the case, we would have a blatant read bug. As I read the current code, _any_ error will cause the page to not be marked as up to date.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

