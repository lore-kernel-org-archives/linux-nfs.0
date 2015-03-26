Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:34434 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbbCZPc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2015 11:32:26 -0400
Received: by yhch68 with SMTP id h68so27820268yhc.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2015 08:32:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55142405.3090000@Netapp.com>
References: <20150318205554.GA10716@fieldses.org>
	<5509E824.6070006@Netapp.com>
	<20150318211144.GB10716@fieldses.org>
	<OFB111A6D8.016B8BD5-ON88257E0D.001D174D-88257E0D.005268D6@us.ibm.com>
	<20150319153627.GA20852@fieldses.org>
	<OF38D4D18B.19055EC2-ON88257E0D.0059BA03-88257E0D.005A781F@us.ibm.com>
	<20150320151718.GD2036@fieldses.org>
	<20150320162303.GA18786@infradead.org>
	<20150320182621.GH2036@fieldses.org>
	<CAFX2JfkybBPcqD6A8r-jOkPnkL26=NEuK3zhA6TLn-DVam+kfQ@mail.gmail.com>
	<20150324174916.GA28906@infradead.org>
	<55142405.3090000@Netapp.com>
Date: Thu, 26 Mar 2015 11:32:25 -0400
Message-ID: <CAHQdGtTavsJ5k0taRCBi7CgP1NYjqQmgbQcE-yUkXQOKdQsGpA@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Marc Eshel <eshel@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org, xfs@oss.sgi.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 26, 2015 at 11:21 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Here are my updated numbers!  I tested with files 5G in size: one 100% data, one 100% hole, and one alternating between hole and data every 4K.  I collected data for both v4.1 and v4.2 with and without the READ_PLUS patches:
>
> ##########################
> #                        #
> #   Without READ_PLUS    #
> #                        #
> ##########################
>
>
> NFS v4.1:
>                             Trial
> |---------|---------|---------|---------|---------|---------|---------|
> |         |    1    |    2    |    3    |    4    |    5    | Average |
> |---------|---------|---------|---------|---------|---------|---------|
> |    Data |  8.723s |  7.243s |  8.252s |  6.997s |  6.980s |  7.639s |
> |    Hole |  5.271s |  5.224s |  5.060s |  4.897s |  5.321s |  5.155s |
> |   Mixed |  8.050s | 10.057s |  7.919s |  8.060s |  9.557s |  8.729s |
> |---------|---------|---------|---------|---------|---------|---------|
>
>
>
>
> NFS v4.2:
>                             Trial
> |---------|---------|---------|---------|---------|---------|---------|
> |         |    1    |    2    |    3    |    4    |    5    | Average |
> |---------|---------|---------|---------|---------|---------|---------|
> |    Data |  6.707s |  7.070s |  6.722s |  6.761s |  6.810s |  6.814s |
> |    Hole |  5.152s |  5.149s |  5.213s |  5.206s |  5.312s |  5.206s |
> |   Mixed |  7.979s |  7.985s |  8.177s |  7.772s |  8.280s |  8.039s |
> |---------|---------|---------|---------|---------|---------|---------|
>
>
>
>
>
> #######################
> #                     #
> #   With READ_PLUS    #
> #                     #
> #######################
>
>
> NFS v4.1:
>                             Trial
> |---------|---------|---------|---------|---------|---------|---------|
> |         |    1    |    2    |    3    |    4    |    5    | Average |
> |---------|---------|---------|---------|---------|---------|---------|
> |    Data |  9.082s |  7.008s |  7.116s |  6.771s |  7.902s |  7.576s |
> |    Hole |  5.333s |  5.358s |  5.380s |  5.161s |  5.282s |  5.303s |
> |   Mixed |  8.189s |  8.308s |  9.540s |  7.937s |  8.420s |  8.479s |
> |---------|---------|---------|---------|---------|---------|---------|
>
>
>
>
> NFS v4.2:
>                             Trial
> |---------|---------|---------|---------|---------|---------|---------|
> |         |    1    |    2    |    3    |    4    |    5    | Average |
> |---------|---------|---------|---------|---------|---------|---------|
> |    Data |  7.033s |  6.829s |  7.025s |  6.873s |  7.134s |  6.979s |
> |    Hole |  1.794s |  1.800s |  1.905s |  1.811s |  1.725s |  1.807s |
> |   Mixed |  7.590s |  8.777s |  9.423s | 10.366s |  8.024s |  8.836s |
> |---------|---------|---------|---------|---------|---------|---------|
>

So there is a clear win in the 100% hole case here, but otherwise the
statistical fluctuations are dominating the numbers. Can you get us a
little more stats and then perhaps run the results through nfsometer?

>
>
> On 03/24/2015 01:49 PM, Christoph Hellwig wrote:
>> On Tue, Mar 24, 2015 at 08:43:31AM -0400, Anna Schumaker wrote:
>>>> I don't know, and don't have profiles.  I'll either try to reproduce or
>>>> wait till Anna's back from vacation.
>>>
>>> I'm using whatever functions NFSD already uses for reading files,
>>> which I expect go through the VFS.  Is there a flag that controls
>>> cache behavior?
>>
>> There's the O_DIRECT flag, but that's not what I mean.  If you just
>> wrote to it it's a cached read, if you did unmount the filesystem after
>> writing, or did an echo to /proc/sys/vm/drop_caches you get uncached
>> read behavior.
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
