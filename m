Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35625 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbaD1FXP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 01:23:15 -0400
Received: by mail-pd0-f179.google.com with SMTP id y10so342956pdj.10
        for <linux-nfs@vger.kernel.org>; Sun, 27 Apr 2014 22:23:14 -0700 (PDT)
Message-ID: <535DE5CE.7050600@gmail.com>
Date: Sun, 27 Apr 2014 22:23:26 -0700
From: Dean <seattleplus@gmail.com>
MIME-Version: 1.0
To: Cedric Blancher <cedric.blancher@gmail.com>, Jim Rees <rees@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>	<20140424031216.GA18817@umich.edu> <CALXu0UdsUk2bSWUzOXLHJ1FKtnZMyo0OHJSj=0hQpwwHVu52zw@mail.gmail.com>
In-Reply-To: <CALXu0UdsUk2bSWUzOXLHJ1FKtnZMyo0OHJSj=0hQpwwHVu52zw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 4/24/14, 10:22 AM, Cedric Blancher wrote:
> On 24 April 2014 05:12, Jim Rees <rees@umich.edu> wrote:
>> Cedric Blancher wrote:
>>
>>    Are there any options to improve the Linux NFSv4 performance over a
>>    high latency connection?
>>
>> We did some work along these lines at CITI years ago. As I remember, the
>> main thing was to increase net.ipv4.tcp_[rw]mem on the server side, because
>> tcp auto-tuning was being defeated. This may be less of an issue with your
>> work load, which sounds like many small files rather than one big one.  In
>> theory, NFSv4 delegations should help, but I don't know how well that works.

Along with Jim's work, we followed up with a fair bit, but in general we 
found that nfs clients just can't do well over large rtt due to the slow 
window ramp up time and adverse reaction to packet loss.  Unfortunately 
the only way to overcome these issues (other than using a custom udp 
protocol which isn't supported) is to use multiple TCP connections, 
which is what we do by  using multiple nodes....

I have some basic instructions here on what we do in our environments:
http://researcher.watson.ibm.com/researcher/view_person_subpage.php?id=4427

Dean
