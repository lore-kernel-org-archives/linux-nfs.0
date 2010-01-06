Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62437 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754247Ab0AFDDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 22:03:52 -0500
Date: Wed, 6 Jan 2010 11:03:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jan Kara <jack@suse.cz>, Steve Rago <sar@nec-labs.com>,
        Peter Zijlstra <peterz@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Message-ID: <20100106030346.GA15962@localhost>
References: <20091222015907.GA6223@localhost> <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz> <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost> <1261656281.3596.1.camel@localhost> <20091225055617.GA8595@localhost> <1262190168.7332.6.camel@localhost> <20091231050441.GB19627@localhost> <1262286828.8151.113.camel@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1262286828.8151.113.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond,

On Fri, Jan 01, 2010 at 03:13:48AM +0800, Trond Myklebust wrote:
> On Thu, 2009-12-31 at 13:04 +0800, Wu Fengguang wrote:
> 
> > ---
> >  fs/nfs/inode.c |    5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > --- linux.orig/fs/nfs/inode.c	2009-12-25 09:25:38.000000000 +0800
> > +++ linux/fs/nfs/inode.c	2009-12-25 10:13:06.000000000 +0800
> > @@ -105,8 +105,11 @@ int nfs_write_inode(struct inode *inode,
> >  		ret = filemap_fdatawait(inode->i_mapping);
> >  		if (ret == 0)
> >  			ret = nfs_commit_inode(inode, FLUSH_SYNC);
> > -	} else
> > +	} else if (!radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
> > +				      NFS_PAGE_TAG_LOCKED))
> >  		ret = nfs_commit_inode(inode, 0);
> > +	else
> > +		ret = -EAGAIN;
> >  	if (ret >= 0)
> >  		return 0;
> >  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> 
> The above change improves on the existing code, but doesn't solve the
> problem that write_inode() isn't a good match for COMMIT. We need to
> wait for all the unstable WRITE rpc calls to return before we can know
> whether or not a COMMIT is needed (some commercial servers never require
> commit, even if the client requested an unstable write). That was the
> other reason for the change.

Ah good to know that reason. However we cannot wait for ongoing WRITEs
for unlimited time or pages, otherwise nr_unstable goes up and squeeze 
nr_dirty and nr_writeback to zero, and stall the cp process for a long
time, as demonstrated by the trace (more reasoning in previous email).

> 
> I do, however, agree that the above can provide a nice heuristic for the
> WB_SYNC_NONE case (minus the -EAGAIN error). Mind if I integrate it?

Sure, thank you.

Here is the trace I collected with this patch.
The pipeline is often stalled and throughput is poor..

Thanks,
Fengguang


% vmmon -d 1 nr_writeback nr_dirty nr_unstable

     nr_writeback         nr_dirty      nr_unstable
                0                0                0
                0                0                0
                0                0                0
            31609            71540              146
            45293            60500             2832
            44418            58964             5246
            44927            55903             7806
            44672            55901             8064
            44159            52840            11646
            43120            51317            14224
            43556            48256            16857
            42532            46728            19417
            43044            43672            21977
            42093            42144            24464
            40999            40621            27097
            41508            37560            29657
            40612            36032            32089
            41600            34509            32640
            41600            34509            32640
            41600            34509            32640
            41454            32976            34319
            40466            31448            36843

     nr_writeback         nr_dirty      nr_unstable
            39699            29920            39146
            40210            26864            41707
            39168            25336            44285
            38126            25341            45330
            38144            25341            45312
            37779            23808            47210
            38254            20752            49807
            37358            19224            52239
            36334            19229            53266
            36352            17696            54781
            35438            16168            57231
            35496            13621            59736
            47463                0            61420
            47421                0            61440
            44389                0            64472
            41829                0            67032
            39342                0            69519
            39357                0            69504
            36656                0            72205
            34131                0            74730
            31717                0            77144
            31165                0            77696
            28975                0            79886
            26451                0            82410

     nr_writeback         nr_dirty      nr_unstable
            23873                0            84988
            22992                0            85869
            21586                0            87275
            19027                0            89834
            16467                0            92394
            14765                0            94096
            14781                0            94080
            12080                0            96781
             9391                0            99470
             6831                0           102030
             6589                0           102272
             6589                0           102272
             3669                0           105192
             1089                0           107772
               44                0           108817
                0                0           108861
                0                0           108861
            35186            71874             1679
            32626            71913             4238
            30121            71913             6743
            28802            71913             8062
            26610            71913            10254
            36953            59138            12686
            34473            59114            15191

     nr_writeback         nr_dirty      nr_unstable
            33446            59114            16218
            33408            59114            16256
            30707            59114            18957
            28183            59114            21481
            25988            59114            23676
            25253            59114            24411
            25216            59114            24448
            22953            59114            26711
            35351            44274            29161
            32645            44274            31867
            32384            44274            32128
            32384            44274            32128
            32384            44274            32128
            28928            44274            35584
            26350            44274            38162
            26112            44274            38400
            26112            44274            38400
            26112            44274            38400
            22565            44274            41947
            36989            27364            44434
            35440            27379            45968
            32805            27379            48603
            30245            27379            51163
            28672            27379            52736

     nr_writeback         nr_dirty      nr_unstable
            56047                4            52736
            56051                0            52736
            56051                0            52736
            56051                0            52736
            56051                0            52736
            54279                0            54508
            51846                0            56941
            49158                0            59629
            47987                0            60800
            47987                0            60800
            47987                0            60800
            47987                0            60800
            47987                0            60800
            47987                0            60800
            44612                0            62976
            42228                0            62976
            39650                0            62976
            37236                0            62976
            34658                0            62976
            32226                0            62976
            29722                0            62976
            27161                0            62976
            24674                0            62976
            22242                0            62976

     nr_writeback         nr_dirty      nr_unstable
            19737                0            62976
            17306                0            62976
            14745                0            62976
            12313                0            62976
             9753                0            62976
             7321                0            62976
             4743                0            62976
             2329                0            62976
               43                0            14139
                0                0                0
                0                0                0
                0                0                0

wfg ~% dstat
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  2   9  89   0   0   0|   0     0 | 729B  720B|   0     0 | 875  2136
  6   9  76   8   0   1|   0   352k|9532B 4660B|   0     0 |1046  2091
  3   8  89   0   0   0|   0     0 |1153B  426B|   0     0 | 870  1870
  1   9  89   0   0   0|   0    72k|1218B  246B|   0     0 | 853  1757
  3   8  89   0   0   0|   0     0 | 844B   66B|   0     0 | 865  1695
  2   7  91   0   0   0|   0     0 | 523B   66B|   0     0 | 818  1576
  3   7  90   0   0   0|   0     0 | 901B   66B|   0     0 | 820  1590
  6  11  68  11   0   4|   0   456k|2028k   51k|   0     0 |1560  2756
  7  21  52   0   0  20|   0     0 |  11M  238k|   0     0 |4627  7423
  2  22  51   0   0  24|   0    80k|  10M  230k|   0     0 |4200  6469
  4  19  54   0   0  23|   0     0 |  10M  236k|   0     0 |4277  6629
  3  15  37  31   0  14|   0    64M|5377k  115k|   0     0 |2229  2972
  3  27  45   0   0  26|   0     0 |  10M  237k|   0     0 |4416  6743
  3  20  51   0   0  27|   0  1024k|  10M  233k|   0     0 |4284  6694 ^C
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  5   9  84   2   0   1| 225k  443k|   0     0 |   0     0 | 950  1985
  4  28  25  22   0  21|   0    62M|  10M  235k|   0     0 |4529  6686
  5  23  30  11   0  31|   0    23M|  10M  239k|   0     0 |4570  6948
  2  24  48   0   0  26|   0     0 |  10M  234k|   0     0 |4334  6796
  2  25  34  17   0  22|   0    50M|  10M  236k|   0     0 |4546  6944
  2  29  46   7   0  18|   0    14M|  10M  236k|   0     0 |4411  6998
  2  23  53   0   0  22|   0     0 |  10M  232k|   0     0 |4100  6595
  3  19  20  32   0  26|   0    39M|9466k  207k|   0     0 |3455  4617
  2  13  40  43   0   1|   0    41M| 930B  264B|   0     0 | 906  1545
  3   7  45  43   0   1|   0    57M| 713B  132B|   0     0 | 859  1669
  3   9  47  40   0   1|   0    54M| 376B   66B|   0     0 | 944  1741
  5  25  47   0   0  21|   0    16k|9951k  222k|   0     0 |4227  6697
  5  20  38  14   0  23|   0    36M|9388k  204k|   0     0 |3650  5135
  3  28  46   0   0  24|   0  8192B|  11M  241k|   0     0 |4612  7115
  2  24  49   0   0  25|   0     0 |  10M  234k|   0     0 |4120  6477
  2  25  37  12   0  23|   0    56M|  11M  239k|   0     0 |4406  6237
  3   7  38  44   0   7|   0    48M|1529k   32k|   0     0 |1071  1635
  3   8  41  45   0   2|   0    58M| 602B  198B|   0     0 | 886  1613
  2  25  45   2   0  27|   0  2056k|  10M  228k|   0     0 |4233  6623
  2  24  49   0   0  24|   0     0 |  10M  235k|   0     0 |4292  6815
  2  27  41   8   0  22|   0    50M|  10M  234k|   0     0 |4381  6394
  1   9  41  41   0   7|   0    59M|1790k   38k|   0     0 |1226  1823
  2  26  40  10   0  22|   0    17M|8185k  183k|   0     0 |3584  5410
  1  23  54   0   0  22|   0     0 |  10M  228k|   0     0 |4153  6672
  1  22  49   0   0  28|   0    37M|  11M  239k|   0     0 |4499  6938
  2  15  37  32   0  13|   0    57M|5078k  110k|   0     0 |2154  2903
  3  20  45  21   0  10|   0    31M|4268k   96k|   0     0 |2338  3712
  2  21  55   0   0  21|   0     0 |  10M  231k|   0     0 |4292  6940
  2  22  49   0   0  27|   0    25M|  11M  238k|   0     0 |4338  6677
  2  17  42  19   0  19|   0    53M|8269k  180k|   0     0 |3341  4501
  3  17  45  33   0   2|   0    50M|2083k   49k|   0     0 |1778  2733
  2  23  53   0   0  22|   0     0 |  11M  240k|   0     0 |4482  7108
  2  23  51   0   0  25|   0  9792k|  10M  230k|   0     0 |4220  6563
  3  21  38  15   0  24|   0    53M|  11M  240k|   0     0 |4038  5697
  3  10  41  43   0   3|   0    65M|  80k  660B|   0     0 | 984  1725
  1  23  51   0   0  25|   0  8192B|  10M  230k|   0     0 |4301  6652
  2  21  48   0   0  29|   0     0 |  10M  237k|   0     0 |4267  6956
  2  26  43   5   0  23|   0    52M|  10M  236k|   0     0 |4553  6764
  7   7  34  41   0  10|   0    57M|2596k   56k|   0     0 |1210  1680
  6  21  44  12   0  17|   0    19M|7053k  158k|   0     0 |3194  4902
  4  24  51   0   0  21|   0     0 |  10M  237k|   0     0 |4406  6724
  4  22  53   0   0  21|   0    31M|  10M  237k|   0     0 |4752  7286
  4  15  32  32   0  17|   0    49M|5777k  125k|   0     0 |2379  3015
  5  14  43  34   0   3|   0    48M|1781k   42k|   0     0 |1578  2492
  4  22  42   0   0  32|   0     0 |  10M  236k|   0     0 |4318  6763
  3  22  50   4   0  21|   0  7072k|  10M  236k|   0     0 |4509  6859
  6  21  28  16   0  28|   0    41M|  11M  241k|   0     0 |4289  5928
  7   8  39  44   0   2|   0    40M| 217k 3762B|   0     0 |1024  1763
  4  15  46  28   0   6|   0    39M|2377k   55k|   0     0 |1683  2678
  4  24  45   0   0  26|   0     0 |  10M  232k|   0     0 |4207  6596
  3  24  50   5   0  19|   0    10M|9472k  210k|   0     0 |3976  6122
  5   7  40  46   0   1|   0    32M|1230B   66B|   0     0 | 967  1676
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  5   7  47  40   0   1|   0    39M| 651B   66B|   0     0 | 916  1583
  4  12  54  22   0   7|   0    35M|1815k   41k|   0     0 |1448  2383
  4  22  52   0   0  21|   0     0 |  10M  233k|   0     0 |4258  6705
  4  22  52   0   0  22|   0    24M|  10M  236k|   0     0 |4480  7097
  3  23  48   0   0  26|   0    28M|  10M  234k|   0     0 |4402  6798
  5  12  36  29   0  19|   0    59M|5464k  118k|   0     0 |2358  2963
  4  26  47   4   0  19|   0  5184k|8684k  194k|   0     0 |3786  5852
  4  22  43   0   0  32|   0     0 |  10M  233k|   0     0 |4350  6779
  3  26  44   0   0  27|   0    36M|  10M  233k|   0     0 |4360  6619
  4  11  39  33   0  13|   0    46M|4545k   98k|   0     0 |2159  2600
  3  14  40  40   0   2|   0    46M| 160k 4198B|   0     0 |1070  1610
  4  25  45   0   0  27|   0     0 |  10M  236k|   0     0 |4435  6760
  4  25  48   0   0  24|   0  3648k|  10M  235k|   0     0 |4595  6950
  3  24  29  22   0  21|   0    37M|  10M  236k|   0     0 |4335  6461
  5  11  42  36   0   6|   0    45M|2257k   48k|   0     0 |1440  1755
  5   6  41  47   0   1|   0    43M| 768B  198B|   0     0 | 989  1592
  5  30  47   3   0  15|   0    24k|8598k  192k|   0     0 |3694  5580
  2  23  49   0   0  26|   0     0 |  10M  229k|   0     0 |4319  6805
  4  22  32  20   0  22|   0    26M|  10M  234k|   0     0 |4487  6751
  4  11  24  53   0   8|   0    32M|2503k   55k|   0     0 |1287  1654
  8  10  42  39   0   0|   0    43M|1783B  132B|   0     0 |1054  1900
  6  16  43  27   0   8|   0    24M|2790k   64k|   0     0 |2150  3370
  4  24  51   0   0  21|   0     0 |  10M  231k|   0     0 |4308  6589
  3  24  36  13   0  24|   0  9848k|  10M  231k|   0     0 |4394  6742
  6  10  11  62   0   9|   0    27M|2519k   55k|   0     0 |1482  1723
  3  12  23  61   0   2|   0    34M| 608B  132B|   0     0 | 927  1623
  3  15  38  38   0   6|   0    36M|2077k   48k|   0     0 |1801  2651
  7  25  45   6   0  17|   0  3000k|  11M  241k|   0     0 |5071  7687
  3  26  45   3   0  23|   0    13M|  11M  238k|   0     0 |4473  6650
  4  17  40  21   0  17|   0    37M|6253k  139k|   0     0 |2891  3746
  3  24  48   0   0  25|   0     0 |  10M  238k|   0     0 |4736  7189
  1  28  38   7   0  25|   0  9160k|  10M  232k|   0     0 |4689  7026
  4  17  26  35   0  18|   0    21M|8707k  190k|   0     0 |3346  4488
  4  11  12  72   0   1|   0    29M|1459B  264B|   0     0 | 947  1643
  4  10  20  64   0   1|   0    28M| 728B  132B|   0     0 |1010  1531
  6   8   7  78   0   1|   0    25M| 869B   66B|   0     0 | 945  1620
  5  10  15  69   0   1|   0    27M| 647B  132B|   0     0 |1052  1553
  5  11   0  82   0   1|   0    16M| 724B   66B|   0     0 |1063  1679
  3  22  18  49   0   9|   0    14M|4560k  103k|   0     0 |2931  4039
  3  24  44   0   0  29|   0     0 |  10M  236k|   0     0 |4863  7497
  3  30  42   0   0  24|   0  4144k|  11M  250k|   0     0 |5505  7945
  3  18  13  45   0  20|   0    15M|7234k  157k|   0     0 |3197  4021
  7   9   0  82   0   1|   0    23M| 356B  198B|   0     0 | 979  1738
  3  11   9  77   0   0|   0    22M| 802B  132B|   0     0 | 994  1635
  5   9   1  84   0   2|   0    31M| 834B   66B|   0     0 | 996  1534
  4  10  14  71   0   1|   0    20M| 288B  132B|   0     0 | 976  1627
  4  14  22  59   0   1|   0  8032k| 865k   20k|   0     0 |1222  1589
  4  23  46   0   0  26|   0     0 |  10M  239k|   0     0 |3791  5035
  5  17  43   6   0  29|   0    17M|  10M  233k|   0     0 |3198  4372
  4  19  50   0   0  27|   0     0 |  10M  231k|   0     0 |2952  4447
  5  19  37  14   0  26|   0  8568k|  10M  227k|   0     0 |3562  5251
  3  21  23  25   0  28|   0  9560k|  10M  230k|   0     0 |3390  5038
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  5  19  24  26   0  26|   0    11M|  10M  229k|   0     0 |3282  4749
  4  20   8  39   0  28|   0  7992k|  10M  230k|   0     0 |3302  4488
  4  17   3  47   0  30|   0  8616k|  10M  231k|   0     0 |3440  4909
  5  16  22  25   0  31|   0  6556k|  10M  227k|   0     0 |3291  4671
  3  18  22  24   0  32|   0  5588k|  10M  230k|   0     0 |3345  4822
  4  16  26  25   0  29|   0  4744k|  10M  230k|   0     0 |3331  4854
  3  18  16  37   0  26|   0  4296k|  10M  228k|   0     0 |3056  4139
  3  17  18  25   0  36|   0  3016k|  10M  230k|   0     0 |3239  4623
  4  19  23  26   0  27|   0  2216k|  10M  229k|   0     0 |3331  4777
  4  20  41   8   0  26|   0  8584k|  10M  228k|   0     0 |3434  5114
  4  17  50   0   0  29|   0  1000k|  10M  229k|   0     0 |3151  4878
  2  18  50   1   0  29|   0    32k|  10M  232k|   0     0 |3176  4951
  3  19  51   0   0  28|   0     0 |  10M  232k|   0     0 |3014  4567
  4  17  53   1   0  24|   0    32k|8787k  195k|   0     0 |2768  4382
  3   8  89   0   0   0|   0     0 |4013B 2016B|   0     0 | 866  1653
  3   8  88   0   0   0|   0    16k|1017B    0 |   0     0 | 828  1660
  6   8  86   0   0   0|   0     0 |1320B   66B|   0     0 | 821  1713
  4   8  88   0   0   0|   0     0 | 692B   66B|   0     0 | 806  1665
 
> ------------------------------------------------------------------------------------------------------------ 
> VFS: Ensure that writeback_single_inode() commits unstable writes
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> If the call to do_writepages() succeeded in starting writeback, we do not
> know whether or not we will need to COMMIT any unstable writes until after
> the write RPC calls are finished. Currently, we assume that at least one
> write RPC call will have finished, and set I_DIRTY_DATASYNC by the time
> do_writepages is done, so that write_inode() is triggered.
> 
> In order to ensure reliable operation (i.e. ensure that a single call to
> writeback_single_inode() with WB_SYNC_ALL set suffices to ensure that pages
> are on disk) we need to first wait for filemap_fdatawait() to complete,
> then test for unstable pages.
> 
> Since NFS is currently the only filesystem that has unstable pages, we can
> add a new inode state I_UNSTABLE_PAGES that NFS alone will set. When set,
> this will trigger a callback to a new address_space_operation to call the
> COMMIT.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/fs-writeback.c  |   31 ++++++++++++++++++++++++++++++-
>  fs/nfs/file.c      |    1 +
>  fs/nfs/inode.c     |   16 ----------------
>  fs/nfs/internal.h  |    3 ++-
>  fs/nfs/super.c     |    2 --
>  fs/nfs/write.c     |   33 ++++++++++++++++++++++++++++++++-
>  include/linux/fs.h |    9 +++++++++
>  7 files changed, 74 insertions(+), 21 deletions(-)
> 
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index f6c2155..b25efbb 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -388,6 +388,17 @@ static int write_inode(struct inode *inode, int sync)
>  }
>  
>  /*
> + * Commit the NFS unstable pages.
> + */
> +static int commit_unstable_pages(struct address_space *mapping,
> +		struct writeback_control *wbc)
> +{
> +	if (mapping->a_ops && mapping->a_ops->commit_unstable_pages)
> +		return mapping->a_ops->commit_unstable_pages(mapping, wbc);
> +	return 0;
> +}
> +
> +/*
>   * Wait for writeback on an inode to complete.
>   */
>  static void inode_wait_for_writeback(struct inode *inode)
> @@ -474,6 +485,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
>  	}
>  
>  	spin_lock(&inode_lock);
> +	/*
> +	 * Special state for cleaning NFS unstable pages
> +	 */
> +	if (inode->i_state & I_UNSTABLE_PAGES) {
> +		int err;
> +		inode->i_state &= ~I_UNSTABLE_PAGES;
> +		spin_unlock(&inode_lock);
> +		err = commit_unstable_pages(mapping, wbc);
> +		if (ret == 0)
> +			ret = err;
> +		spin_lock(&inode_lock);
> +	}
>  	inode->i_state &= ~I_SYNC;
>  	if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
>  		if ((inode->i_state & I_DIRTY_PAGES) && wbc->for_kupdate) {
> @@ -532,6 +555,12 @@ select_queue:
>  				inode->i_state |= I_DIRTY_PAGES;
>  				redirty_tail(inode);
>  			}
> +		} else if (inode->i_state & I_UNSTABLE_PAGES) {
> +			/*
> +			 * The inode has got yet more unstable pages to
> +			 * commit. Requeue on b_more_io
> +			 */
> +			requeue_io(inode);
>  		} else if (atomic_read(&inode->i_count)) {
>  			/*
>  			 * The inode is clean, inuse
> @@ -1050,7 +1079,7 @@ void __mark_inode_dirty(struct inode *inode, int flags)
>  
>  	spin_lock(&inode_lock);
>  	if ((inode->i_state & flags) != flags) {
> -		const int was_dirty = inode->i_state & I_DIRTY;
> +		const int was_dirty = inode->i_state & (I_DIRTY|I_UNSTABLE_PAGES);
>  
>  		inode->i_state |= flags;
>  
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 6b89132..67e50ac 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -526,6 +526,7 @@ const struct address_space_operations nfs_file_aops = {
>  	.migratepage = nfs_migrate_page,
>  	.launder_page = nfs_launder_page,
>  	.error_remove_page = generic_error_remove_page,
> +	.commit_unstable_pages = nfs_commit_unstable_pages,
>  };
>  
>  /*
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index faa0918..8341709 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -97,22 +97,6 @@ u64 nfs_compat_user_ino64(u64 fileid)
>  	return ino;
>  }
>  
> -int nfs_write_inode(struct inode *inode, int sync)
> -{
> -	int ret;
> -
> -	if (sync) {
> -		ret = filemap_fdatawait(inode->i_mapping);
> -		if (ret == 0)
> -			ret = nfs_commit_inode(inode, FLUSH_SYNC);
> -	} else
> -		ret = nfs_commit_inode(inode, 0);
> -	if (ret >= 0)
> -		return 0;
> -	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> -	return ret;
> -}
> -
>  void nfs_clear_inode(struct inode *inode)
>  {
>  	/*
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 29e464d..7bb326f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -211,7 +211,6 @@ extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
>  extern struct workqueue_struct *nfsiod_workqueue;
>  extern struct inode *nfs_alloc_inode(struct super_block *sb);
>  extern void nfs_destroy_inode(struct inode *);
> -extern int nfs_write_inode(struct inode *,int);
>  extern void nfs_clear_inode(struct inode *);
>  #ifdef CONFIG_NFS_V4
>  extern void nfs4_clear_inode(struct inode *);
> @@ -253,6 +252,8 @@ extern int nfs4_path_walk(struct nfs_server *server,
>  extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
>  
>  /* write.c */
> +extern int nfs_commit_unstable_pages(struct address_space *mapping,
> +		struct writeback_control *wbc);
>  extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
>  #ifdef CONFIG_MIGRATION
>  extern int nfs_migrate_page(struct address_space *,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ce907ef..805c1a0 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -265,7 +265,6 @@ struct file_system_type nfs_xdev_fs_type = {
>  static const struct super_operations nfs_sops = {
>  	.alloc_inode	= nfs_alloc_inode,
>  	.destroy_inode	= nfs_destroy_inode,
> -	.write_inode	= nfs_write_inode,
>  	.statfs		= nfs_statfs,
>  	.clear_inode	= nfs_clear_inode,
>  	.umount_begin	= nfs_umount_begin,
> @@ -334,7 +333,6 @@ struct file_system_type nfs4_referral_fs_type = {
>  static const struct super_operations nfs4_sops = {
>  	.alloc_inode	= nfs_alloc_inode,
>  	.destroy_inode	= nfs_destroy_inode,
> -	.write_inode	= nfs_write_inode,
>  	.statfs		= nfs_statfs,
>  	.clear_inode	= nfs4_clear_inode,
>  	.umount_begin	= nfs_umount_begin,
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index d171696..910be28 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -441,7 +441,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>  	spin_unlock(&inode->i_lock);
>  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
> -	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> +	mark_inode_unstable_pages(inode);
>  }
>  
>  static int
> @@ -1406,11 +1406,42 @@ int nfs_commit_inode(struct inode *inode, int how)
>  	}
>  	return res;
>  }
> +
> +int nfs_commit_unstable_pages(struct address_space *mapping,
> +		struct writeback_control *wbc)
> +{
> +	struct inode *inode = mapping->host;
> +	int flags = FLUSH_SYNC;
> +	int ret;
> +
> +	/* Don't commit yet if this is a non-blocking flush and there are
> +	 * outstanding writes for this mapping.
> +	 */
> +	if (wbc->sync_mode != WB_SYNC_ALL &&
> +	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
> +		    NFS_PAGE_TAG_LOCKED)) {
> +		mark_inode_unstable_pages(inode);
> +		return 0;
> +	}
> +	if (wbc->nonblocking)
> +		flags = 0;
> +	ret = nfs_commit_inode(inode, flags);
> +	if (ret > 0)
> +		ret = 0;
> +	return ret;
> +}
> +
>  #else
>  static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>  {
>  	return 0;
>  }
> +
> +int nfs_commit_unstable_pages(struct address_space *mapping,
> +		struct writeback_control *wbc)
> +{
> +	return 0;
> +}
>  #endif
>  
>  long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 9147ca8..ea0b7a3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -602,6 +602,8 @@ struct address_space_operations {
>  	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
>  					unsigned long);
>  	int (*error_remove_page)(struct address_space *, struct page *);
> +	int (*commit_unstable_pages)(struct address_space *,
> +			struct writeback_control *);
>  };
>  
>  /*
> @@ -1635,6 +1637,8 @@ struct super_operations {
>  #define I_CLEAR			64
>  #define __I_SYNC		7
>  #define I_SYNC			(1 << __I_SYNC)
> +#define __I_UNSTABLE_PAGES	9
> +#define I_UNSTABLE_PAGES	(1 << __I_UNSTABLE_PAGES)
>  
>  #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
>  
> @@ -1649,6 +1653,11 @@ static inline void mark_inode_dirty_sync(struct inode *inode)
>  	__mark_inode_dirty(inode, I_DIRTY_SYNC);
>  }
>  
> +static inline void mark_inode_unstable_pages(struct inode *inode)
> +{
> +	__mark_inode_dirty(inode, I_UNSTABLE_PAGES);
> +}
> +
>  /**
>   * inc_nlink - directly increment an inode's link count
>   * @inode: inode
> 
