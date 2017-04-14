Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36036 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751502AbdDNVWO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2017 17:22:14 -0400
Received: by mail-io0-f193.google.com with SMTP id x86so20036385ioe.3
        for <linux-nfs@vger.kernel.org>; Fri, 14 Apr 2017 14:22:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org> <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 14 Apr 2017 17:22:13 -0400
Message-ID: <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
Subject: Re: [nfsv4] Inter server-side copy performance
To: "Mora, Jorge" <Jorge.Mora@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 14, 2017 at 4:09 PM, Mora, Jorge <Jorge.Mora@netapp.com> wrote:
> On 4/13/17, 11:45 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>> On Wed, Apr 12, 2017 at 02:47:30PM +0000, Mora, Jorge wrote:
>> > The following shows a comparison between inter server-side copy and a =
traditional copy.
>>
>> Thanks for doing this!  Adding the linux-nfs list, I hope that's OK.
>>
>> > Setup:
>> >     Client: 16 CPUs, 32GB
>> >     SRC server: 4 CPUs, 8GB
>> >     DST server: 4 CPUs, 8GB
>>
>> Could you also tell us about the network?  How much bandwidth is
>> available between the two servers, and between the each server and the
>> client?  Disk bandwidth might be useful to know too.
>
> Client:     pair    (1000baseT/Full)
> SRC Server: ricoh   (1000baseT/Full)
> DST Server: haddock (1000baseT/Full)
>
> Transfer from source server to client:
> [mora@pair test]$ scp ricoh:/home/exports/nfstest_ssc_source_file /dev/nu=
ll
> nfstest_ssc_source_file                       100% 8192MB 110.7MB/s   01:=
14
>
> Transfer from destination server to client:
> [mora@pair test]$ scp haddock:/home/exports/nfstest_ssc_source_file /dev/=
null
> nfstest_ssc_source_file                       100% 8192MB 112.2MB/s   01:=
13
>
> Transfer from source to destination server:
> [mora@haddock ~]$ scp ricoh:/home/exports/nfstest_ssc_source_file /dev/nu=
ll
> nfstest_ssc_source_file                       100% 8192MB 110.7MB/s   01:=
14
>
> Disk I/O on source server:
> [mora@ricoh ~]$ sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
> [mora@ricoh ~]$ dd if=3D/home/exports/nfstest_ssc_source_file of=3D/dev/n=
ull bs=3D8k count=3D1024k
> 1048576+0 records in
> 1048576+0 records out
> 8589934592 bytes (8.6 GB) copied, 56.8953 s, 151 MB/s
> [mora@ricoh ~]$ sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
> [mora@ricoh ~]$ dd if=3D/dev/zero of=3D/home/exports/test bs=3D8k count=
=3D1024k
> 1048576+0 records in
> 1048576+0 records out
> 8589934592 bytes (8.6 GB) copied, 46.9064 s, 183 MB/s
>
> Disk I/O on destination server:
> [mora@haddock ~]$ sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
> [mora@haddock ~]$ dd if=3D/home/exports/nfstest_ssc_source_file of=3D/dev=
/null bs=3D8k count=3D1024k
> 1048576+0 records in
> 1048576+0 records out
> 8589934592 bytes (8.6 GB) copied, 57.3356 s, 150 MB/s
> [mora@haddock ~]$ sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
> [mora@haddock ~]$ dd if=3D/dev/zero of=3D/home/exports/test bs=3D8k count=
=3D1024k
> 1048576+0 records in
> 1048576+0 records out
> 8589934592 bytes (8.6 GB) copied, 47.3809 s, 181 MB/s
>
>> >     All machines are running 4.10.0-ssc-02242017.1345,
>> >       4.10.0 kernel on top RHEL 7.3 with Olga=E2=80=99s SSC patches 02=
242017.tgz (asynchronous SSC)
>> > Test:
>> >     The test runs 10 times for each copy size and the average is compa=
red.
>> >     The servers are mounted and un-mounted for each copy (using defaul=
t mount options)
>> >     Testing copy size: 1KB =E2=80=93 4GB, NOTE: the last copy is 4GB-1=
 bytes, the maximum copy_file_range() accepts.
>>
>> If the client unmounts the servers, but if the servers keep their
>> exports mounted then the performance may depend on whether data is
>> already cached on the source server, since all these copies fit in RAM.
>
> Good point, I will clear the VM caches using "echo 3 > /proc/sys/vm/drop_=
caches"
> on both servers before each copy.
>
>> Are you timing just the copy_file_range() call, or do you include a
>> following sync?
>
> I am timing right before calling copy_file_range() up to doing an fsync()=
 and close() of the destination file.
> For the traditional copy is the same, I am timing right before the first =
read on the source file up to the
> fsync() and close() of the destination file.

Why should do we need a sync after copy_file_range(). kernel
copy_file_range() will send the commits for any unstable copies it
received.

>
>> > Results:
>> >     For a copy size below 16MB, traditional copy runs faster than serv=
er-side copy
>> >     For a copy size of 32MB and above, server-side copy is at least 30=
% faster.
>> >     For a copy size of 128MB and above, server-side copy is about 50% =
faster.
>> >     For the 1GB and 2GB copy sizes, the performance improvement is onl=
y about 30-40%, investigating why this is happening.
>>
>> Might also be interesting to look at performance when copying a larger
>> file with multiple copy_file_range() calls.
>
> I will do this as well.
>
>
> --Jorge
>
>> --b.
>>
>> > *** Inter-SSC performance test
>> >     TEST: Running test 'perf02'
>> >
>> > Performance degradation:
>> >     INFO: 00:08:50.035165 - perf02 copy with size 1KB
>> >     INFO: 00:09:01.302004 - Server-side COPY: 0.104049992561 seconds
>> >     INFO: 00:09:01.302206 - Traditional COPY: 0.0319610118866 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 1KB file: 225%
>> >     INFO: 00:09:01.302378 - perf02 copy with size 2KB
>> >     INFO: 00:09:12.332144 - Server-side COPY: 0.0923588514328 seconds
>> >     INFO: 00:09:12.332335 - Traditional COPY: 0.033596777916 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 2KB file: 174%
>> >     INFO: 00:09:12.332510 - perf02 copy with size 4KB
>> >     INFO: 00:09:23.320714 - Server-side COPY: 0.100715565681 seconds
>> >     INFO: 00:09:23.320915 - Traditional COPY: 0.0336240530014 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 4KB file: 199%
>> >     INFO: 00:09:23.321086 - perf02 copy with size 8KB
>> >     INFO: 00:09:34.542515 - Server-side COPY: 0.0881641149521 seconds
>> >     INFO: 00:09:34.542742 - Traditional COPY: 0.0336608886719 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 8KB file: 161%
>> >     INFO: 00:09:34.542924 - perf02 copy with size 16KB
>> >     INFO: 00:09:45.439424 - Server-side COPY: 0.0939898014069 seconds
>> >     INFO: 00:09:45.439630 - Traditional COPY: 0.0277063846588 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 16KB file: 239%
>> >     INFO: 00:09:45.439795 - perf02 copy with size 32KB
>> >     INFO: 00:09:56.103480 - Server-side COPY: 0.0798309087753 seconds
>> >     INFO: 00:09:56.103691 - Traditional COPY: 0.0335722208023 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 32KB file: 137%
>> >     INFO: 00:09:56.103848 - perf02 copy with size 64KB
>> >     INFO: 00:10:07.217026 - Server-side COPY: 0.106491327286 seconds
>> >     INFO: 00:10:07.217228 - Traditional COPY: 0.034387588501 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 64KB file: 209%
>> >     INFO: 00:10:07.217400 - perf02 copy with size 128KB
>> >     INFO: 00:10:18.022320 - Server-side COPY: 0.105627346039 seconds
>> >     INFO: 00:10:18.022516 - Traditional COPY: 0.0511318922043 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 128KB file: 106%
>> >     INFO: 00:10:18.022686 - perf02 copy with size 256KB
>> >     INFO: 00:10:29.452353 - Server-side COPY: 0.124787020683 seconds
>> >     INFO: 00:10:29.452538 - Traditional COPY: 0.0552408218384 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 256KB file: 125%
>> >     INFO: 00:10:29.452713 - perf02 copy with size 512KB
>> >     INFO: 00:10:41.357315 - Server-side COPY: 0.110602092743 seconds
>> >     INFO: 00:10:41.357489 - Traditional COPY: 0.0643961668015 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 512KB file: 71%
>> >     INFO: 00:10:41.357656 - perf02 copy with size 1MB
>> >     INFO: 00:10:52.704159 - Server-side COPY: 0.118950200081 seconds
>> >     INFO: 00:10:52.704341 - Traditional COPY: 0.0703304767609 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 1MB file: 69%
>> >     INFO: 00:10:52.704499 - perf02 copy with size 2MB
>> >     INFO: 00:11:05.367265 - Server-side COPY: 0.13633646965 seconds
>> >     INFO: 00:11:05.367451 - Traditional COPY: 0.103643512726 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 2MB file: 31%
>> >     INFO: 00:11:05.367614 - perf02 copy with size 4MB
>> >     INFO: 00:11:18.872004 - Server-side COPY: 0.181165075302 seconds
>> >     INFO: 00:11:18.872204 - Traditional COPY: 0.164586114883 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 4MB file: 10%
>> >     INFO: 00:11:18.872368 - perf02 copy with size 8MB
>> >     INFO: 00:11:35.093071 - Server-side COPY: 0.29020409584 seconds
>> >     INFO: 00:11:35.093297 - Traditional COPY: 0.283315181732 seconds
>> >     FAIL: SSC should outperform traditional copy, performance degradat=
ion for a 8MB file: 2%
>> >
>> > Performance gain:
>> >     INFO: 00:11:35.093446 - perf02 copy with size 16MB
>> >     INFO: 00:11:54.779844 - Server-side COPY: 0.455569577217 seconds
>> >     INFO: 00:11:54.780038 - Traditional COPY: 0.506252598763 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 16MB file: 11%
>> >     INFO: 00:11:54.780185 - perf02 copy with size 32MB
>> >     INFO: 00:12:22.415131 - Server-side COPY: 0.71369125843 seconds
>> >     INFO: 00:12:22.415319 - Traditional COPY: 0.93473637104 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 32MB file: 30%
>> >     INFO: 00:12:22.415466 - perf02 copy with size 64MB
>> >     INFO: 00:13:03.498260 - Server-side COPY: 1.23845338821 seconds
>> >     INFO: 00:13:03.498456 - Traditional COPY: 1.73098192215 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 64MB file: 39%
>> >     INFO: 00:13:03.498637 - perf02 copy with size 128MB
>> >     INFO: 00:14:11.502475 - Server-side COPY: 2.22639911175 seconds
>> >     INFO: 00:14:11.502896 - Traditional COPY: 3.34778087139 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 128MB file: 50%
>> >     INFO: 00:14:11.503102 - perf02 copy with size 256MB
>> >     INFO: 00:16:12.323350 - Server-side COPY: 4.29401872158 seconds
>> >     INFO: 00:16:12.323537 - Traditional COPY: 6.54622249603 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 256MB file: 52%
>> >     INFO: 00:16:12.323703 - perf02 copy with size 512MB
>> >     INFO: 00:19:58.311598 - Server-side COPY: 8.3841770649 seconds
>> >     INFO: 00:19:58.311793 - Traditional COPY: 12.9200412273 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 512MB file: 54%
>> >     INFO: 00:19:58.311935 - perf02 copy with size 1GB
>> >     INFO: 00:26:01.275809 - Server-side COPY: 14.5967838049 seconds
>> >     INFO: 00:26:01.276020 - Traditional COPY: 20.1957453728 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 1GB file: 38%
>> >     INFO: 00:26:01.276175 - perf02 copy with size 2GB
>> >     INFO: 00:35:29.990220 - Server-side COPY: 23.606795764 seconds
>> >     INFO: 00:35:29.990432 - Traditional COPY: 31.4261539459 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 2GB file: 33%
>> >     INFO: 00:35:29.990580 - perf02 copy with size 4GB
>> >     INFO: 00:53:17.198827 - Server-side COPY: 41.2261408091 seconds
>> >     INFO: 00:53:17.199033 - Traditional COPY: 62.9210350513 seconds
>> >     PASS: SSC should outperform traditional copy, performance improvem=
ent for a 4GB file: 52%
>> >     TIME: 44m27.164286s
>> >
>> > Logfile: /home/mora/logs/nfstest_ssc_20170412000849.log
>> >
>> > 23 tests (9 passed, 14 failed)
>> >
>> > Total time: 44m28.334177s
>> >
>> >
>> >
>> > --Jorge
>> >
>
