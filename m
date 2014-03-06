Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35280 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaCFSux convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 13:50:53 -0500
Received: by mail-ie0-f172.google.com with SMTP id as1so3216058iec.17
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 10:50:52 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com>
Date: Thu, 6 Mar 2014 13:50:50 -0500
Cc: Jim Rees <rees@umich.edu>, bhawley@luminex.com, Brown Neil <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <B454F556-9381-4DB7-B864-EC066DBEAC63@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <20140306173632.GA18545@umich.edu> <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com>
To: Andrew Martin <amartin@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 13:35, Andrew Martin <amartin@xes-inc.com> wrote:

>> From: "Jim Rees" <rees@umich.edu>
>> Why would a bunch of blocked apaches cause high load and reboot?
> What I believe happens is the apache child processes go to serve
> these requests and then block in uninterruptable sleep. Thus, there
> are fewer and fewer child processes to handle new incoming requests.
> Eventually, apache would normally kill said children (e.g after a 
> child handles a certain number of requests), but it cannot kill them
> because they are in uninterruptable sleep. As more and more incoming
> requests are queued (and fewer and fewer child processes are available
> to serve the requests), the load climbs.

Does ‘top’ support this theory? Presumably you should see a handful of non-sleeping apache threads dominating the load when it happens.

Why is the server becoming ‘unavailable’ in the first place? Are you taking it down?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

