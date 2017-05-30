Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28192 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdE3VD1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 17:03:27 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: GSS sequence number window
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170530193419.GA9371@fieldses.org>
Date: Tue, 30 May 2017 17:03:24 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3E3205C9-1560-4A8A-B506-201240B48406@oracle.com>
References: <63736845-2BD3-4EE1-AC12-0BD21A9ABEF2@oracle.com> <20170530193419.GA9371@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 30, 2017, at 3:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, May 30, 2017 at 02:58:00PM -0400, Chuck Lever wrote:
>> Hey Bruce!
>> 
>> While testing with sec=krb5 and sec=krb5i, I noticed a lot of
>> spurious connection loss, especially when I wanted to run a
>> CPU-intensive workload on my NFS server at the same time I
>> was testing.
>> 
>> I added a pr_err() in gss_check_seq_num, and ran a fio job
>> on a vers=3,sec=sys,proto=tcp mount (server is exporting a
>> tmpfs). On the server, I rebuilt a kernel source tree cscope
>> database at the same time.
>> 
>> May 29 17:53:13 klimt kernel: gss_check_seq_num: seq_num = 250098, sd_max = 250291, GSS_SEQ_WIN = 128
>> May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num = 937816, sd_max = 938171, GSS_SEQ_WIN = 128
>> May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num = 938544, sd_max = 938727, GSS_SEQ_WIN = 128
>> May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num = 938543, sd_max = 938727, GSS_SEQ_WIN = 128
>> May 29 17:53:34 klimt kernel: gss_check_seq_num: seq_num = 939344, sd_max = 939549, GSS_SEQ_WIN = 128
>> May 29 17:53:35 klimt kernel: gss_check_seq_num: seq_num = 965007, sd_max = 965176, GSS_SEQ_WIN = 128
>> May 29 17:54:01 klimt kernel: gss_check_seq_num: seq_num = 1799710, sd_max = 1799982, GSS_SEQ_WIN = 128
>> May 29 17:54:02 klimt kernel: gss_check_seq_num: seq_num = 1831165, sd_max = 1831353, GSS_SEQ_WIN = 128
>> May 29 17:54:04 klimt kernel: gss_check_seq_num: seq_num = 1883583, sd_max = 1883761, GSS_SEQ_WIN = 128
>> May 29 17:54:07 klimt kernel: gss_check_seq_num: seq_num = 1959316, sd_max = 1959447, GSS_SEQ_WIN = 128
>> 
>> RFC 2203 suggests there's no risk to using a large window.
>> My first thought was to make the sequence window larger
>> (say 2048) but I've seen stragglers outside even that large
>> a window.
>> 
>> Any thoughts about why there are these sequence number
>> outliers?
> 
> No, alas.
> 
> The server's where it's easier to catch, but it'd be interesting to know
> what's going on on the client side when this happens.
> 
> Might be interesting to know just what the operation (or compound ops)
> are in the bad cases, in case there's some pattern.

It appears to happen more frequently with a 100% read
workload that accesses multiple files.


> Might also be interesting to check where exactly in the client code the
> sequence number is assigned and where in the server code it's checked,
> and think about where they might get queued up or reordered in between.
> 
> Is it possible there are retries involved?

It's hard to tell, since disconnect means there will be
a recorded retransmission.


> Does increasing the number of server threads help?

Yes, but it doesn't fully address the issue.


> I don't think it'd be a problem to increase the sequence window.

Increasing the window to 1024 does not seem to help.


--
Chuck Lever



