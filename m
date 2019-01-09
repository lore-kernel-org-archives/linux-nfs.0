Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B89A8C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 19:39:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5182E20859
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 19:39:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="ckFPIniD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728216AbfAITja (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 14:39:30 -0500
Received: from mail-vs1-f68.google.com ([209.85.217.68]:46706 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727123AbfAITja (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2019 14:39:30 -0500
Received: by mail-vs1-f68.google.com with SMTP id n10so5475005vso.13
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jan 2019 11:39:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bvxonEJgsf2PcBnqJU7JRJuIVIb8yNR2oNLsbFxnT5k=;
        b=ckFPIniDn6J3+hbBks/of4hG+NfnHMXnoM/hXlm/jE/+KW13NGfe6CDuxdMFCz3fk1
         M+8C2eZWRwyX+Ukkbyi7VYWTn0agA2NH7lpTOXYuPBK15dYbbA5ieK8/MQNkliZBZ8AK
         tvwYjODCCcrF0zpYD2eBSE9M+V2mHlo+EfMDRChhP9FfuICHw6RBjvErUDgnEtKzODDC
         PXbNOVB77qoUeZqgK9DGjFHqclmMY7PgkGsLwwNTKOH6sWeCoeqOqdkiXeAUPCaVa4vu
         FW8SGG7Qa45xHVTNEJhzJdPlojD5M1PdYVyKdPQYcYs5wLN1KbY8EszLqSviUCCFB8J5
         psUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=bvxonEJgsf2PcBnqJU7JRJuIVIb8yNR2oNLsbFxnT5k=;
        b=bnJNM/OaoxJ9Jie2se0N5VOEUmulhyp3b99fdP9sZRVVTdJfJKE8PocmjEAVNu9sta
         SkntuF5G5JLWYTpGjDkOxO8wdjgOAVMSV4I5rmkudFln6G7fTo+4tynGlvmbnH+prZ1j
         B1dN1Bl4Q60e/qNh/ulyq6QzvRIO/E3FaCnFeq1u1Tb2pkjftVnwlLSvESiLwfd2xcFy
         qM6je0vqW+y1UUaBykb8N8A2kv0AsAWp591yAyzTPIi9TSyFtNfgCgosszFvz/HR5jIu
         hfm/ZxUc49ufx4Ps7L6c8ja2i9vGF5uohrggZrLhxsbQAMA4fuxsrvc/XMb9ohkpjdWI
         43MA==
X-Gm-Message-State: AJcUukcH/s9lBE/Ea5OFyJMzM+sCibwdtO89hNEJKdRm4IcyVSINSho6
        VkNfOgHLfD1mSK4IU7QS5IuSNy0lNvNVLAbuF7mmtw==
X-Google-Smtp-Source: ALg8bN68RrO07lgAEM1Z6qJ2jG9AhKQ6LgevdRBD/Kj8plj/70myB0znWRrwFA0ATwPUwzibuoUwkrvp3/OFrV0VX9g=
X-Received: by 2002:a67:e242:: with SMTP id w2mr3048871vse.134.1547062767532;
 Wed, 09 Jan 2019 11:39:27 -0800 (PST)
MIME-Version: 1.0
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
In-Reply-To: <20170428172535.7945-1-trond.myklebust@primarydata.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Wed, 9 Jan 2019 14:39:16 -0500
Message-ID: <CAN-5tyEp5=bF2mFjTCs2K2NdKWLY=msqN-5c94hwuXSm3QTDAw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Fun with the multipathing code
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

Do you have any plans for this patch set?

I applied the patches on top of 4.20-rc7 kernel I had and tested it
(linux to linux) with iozone on the hardware (40G link with Mellanox
CX-5 card).

Results seem to show read IO improvement from 1.9GB to 3.9GB. Write IO
speed seems to be the same (disk bound I'm guessing). I also tried
mounting tmpfs. Same thing.

Seems like a useful feature to include?

Some raw numbers I got. Each nconnect=X value is just a single data point.

With nconnect=10
        Command line used: /home/kolga/iozone3_482/src/current/iozone
-i0 -i1 -s52m -y2k -az -I
        Output is in kBytes/sec
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7820    10956    20960    20927
           53248       4    14871    21305    38743    38242
           53248       8    27803    35001    75568    75830
           53248      16    47452    59596   132513   130921
           53248      32    70572    84940   234902   233423
           53248      64    94774   101237   355664   354372
           53248     128   114667   119413   523245   524855
           53248     256   132340   137530   682411   681260
           53248     512   143172   146157   784144   356064
           53248    1024   148874   154177  1013764   982943
           53248    2048   144311   161233  1282095  1592057
           53248    4096   164679   169837  1637788  2438329
           53248    8192   159221   142882   188536  1523659
           53248   16384   169236    96996  3914910  1875398

With nconnect=9
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7833    10991    20893    20910
           53248       4    15254    21136    40030    37510
           53248       8    28077    37834    76688    67560
           53248      16    47850    60174   137175   135266
           53248      32    70653    85120   240219   235160
           53248      64    96742   103856   364931   363556
           53248     128   115002   119222   526446   517589
           53248     256   132349   137254   684606   693748
           53248     512   142849   147385   838735   876868
           53248    1024   149612   152187  1060375   968514
           53248    2048   150830   156006  1476364  1689987
           53248    4096   163228   168421  1000338  1645183
           53248    8192   165049   151047  3168655  3274393
           53248   16384   166007   175972   743835  3817903

With nconnect=8
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7118    10321    20281    20353
           53248       4    13960    20445    39233    39160
           53248       8    24688    36543    74964    75111
           53248      16    44674    57346   131362   130294
           53248      32    67547    82716   231881   228998
           53248      64    94195   103270   345326   343389
           53248     128   116830   119816   521772   511537
           53248     256   133709   137917   682126   693098
           53248     512   143913   148801   878939   860046
           53248    1024   150329   154027  1041977  1028612
           53248    2048   157680   158844     7378  1486753
           53248    4096   159543   160027  2441901  2168589
           53248    8192   165155   160193  2515452  3142285
           53248   16384   169411   176009  2385325  3894130

With nconnect=7
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7574    10593    20459    20381
           53248       4    15064    20928    39865    39760
           53248       8    27696    36864    74300    65721
           53248      16    46960    59010   128354   127600
           53248      32    68841    83578   230226   227369
           53248      64    93114   100612   342303   331331
           53248     128   112599   116108   498004   508645
           53248     256   130668   136554   653718   634570
           53248     512   142318   146749   805566   807056
           53248    1024   148693   152493   965095   974736
           53248    2048   157342   161170  1794490  1697579
           53248    4096   144672   161154  2371227  2089308
           53248    8192   148515   172814  3098132   766539
           53248   16384   152801   143075  3799398  3778023

With nconnect=6
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7832    11103    21119    21254
           53248       4    15490    21607    40520    40215
           53248       8    25519    37333    78626    77118
           53248      16    47885    54596   139343   138482
           53248      32    71914    85094   239720   237024
           53248      64    93901   100491   383238   377849
           53248     128    95497   119289   545658   533312
           53248     256   131614   137665   726717   716209
           53248     512   143397   147452   896038   869623
           53248    1024   149938   153885  1057554  1062727
           53248    2048   157542   159369  1750302  1691100
           53248    4096   163450   162691  2524086  2622917
           53248    8192   162439   153065  3320433  3286189
           53248   16384   153553   166918  3873279  3855965

With nconnect=5
                                                             random
random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7592    10794    20382    20251
           53248       4    15068    21096    41136    41865
           53248       8    27606    37260    74947    74655
           53248      16    47387    59806   137103   135962
           53248      32    70402    83767   244301   241492
           53248      64    95702   103042   361709   356424
           53248     128   114189   118505   564857   556585
           53248     256   132799   137856   751432   726667
           53248     512   143233   146747   900493   921180
           53248    1024   150787   154337  1106200  1088739
           53248    2048   156873   161403  1133588  1709520
           53248    4096   163741   166672  2468622  2275947
           53248    8192   147689   165501  2969179  2943782
           53248   16384   157076   143898  3468473  3580892

With nconnect=4
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7280    10499    20140    21610
           53248       4    15003    20658    39282    39084
           53248       8    27440    36211    72983    74006
           53248      16    46702    58114   130113   129372
           53248      32    67942    81592   237173   246333
           53248      64    92098    98403   351618   349844
           53248     128   117327   120451   492681   480222
           53248     256   134457   137616   676207   666874
           53248     512   144648   148179   853880   855267
           53248    1024   151171   156382  1108038  1075847
           53248    2048   157698   161736  1704862  1659547
           53248    4096   164955   163237     9991  2274603
           53248    8192   167987   173542  3189440  1304661
           53248   16384   160230   158367   616211  1008327

With nconnect=3
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7954    11188    21786    21304
           53248       4    15574    21973    41739    40116
           53248       8    26917    38019    77460    77323
           53248      16    47879    60593   140885   139938
           53248      32    69304    83709   250196   247017
           53248      64    95273   102929   371638   362578
           53248     128   113436   118636   504672   495772
           53248     256   131659   136857   749558   739310
           53248     512   142581   146588   933209   907939
           53248    1024   149502   152321  1092066  1093344
           53248    2048   156992   162151  1821551  1772388
           53248    4096   164692   170124  2530693  2442783
           53248    8192   169409   175014  2795110  2795262
           53248   16384   171873   176216  3088432  3172946
With nconnect=2
                                                               random
  random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7653    10723    20632    20970
           53248       4    15232    21710    43017    42909
           53248       8    27894    38009    80566    80249
           53248      16    47392    60132   140226   138809
           53248      32    72166    84713   240219   240935
           53248      64    95449   102520   392916   387097
           53248     128   113915   118447   592994   579702
           53248     256   132337   136397   808895   782690
           53248     512   142757   147276  1023450   980987
           53248    1024   149803   153748  1232539  1200873
           53248    2048   117144   142496  1726862  1846521
           53248    4096   129211   168913  2327366  2035403
           53248    8192   168842   173977  2079450   859542
           53248   16384   170514   133000  2450596   856588

With nconnect=1
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2     7287    10482    20808    20586
           53248       4    14282    20916    41216    40532
           53248       8    26230    36606    76589    79005
           53248      16    45838    59445   142976   141382
           53248      32    70513    84601   250468   247247
           53248      64    95128   103600   373719   377915
           53248     128   116702   121174   571526   558482
           53248     256   133131   137286   720249   702101
           53248     512   140870   145269   907632   894129
           53248    1024   148632   152558  1025853  1071471
           53248    2048    69684    68052  1640169  1587587
           53248    4096    57389    65044  1932496  1923277
           53248    8192    65201    75412  1896445  1880839
           53248   16384    86395   109635  1784491  1777077


Mounting a tmpfs instead of the disk
nconnect=10
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    20766    21097    21248    21096
           53248       4    38718    39837    40282    40562
           53248       8    70787    73029    75134    75473
           53248      16   129871   135244   137464   137202
           53248      32   206931   225844   246440   243423
           53248      64   307101   324226   362781   363964
           53248     128   423743   437825   533503   539324
           53248     256   549566   600099   726419   756622
           53248     512   658211   723361   890941   902508
           53248    1024   771731   898627  1079691  1125845
           53248    2048   904072  1047097  1746060  1814433
           53248    4096  1197609  1278558  1780285  2390797
           53248    8192  1022231  1523377  1463727  1304735
           53248   16384  1321716  1716730  3913052  3861092

nconnect=9
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    18595    19418    19935    19555
           53248       4    38048    38871    39015    39058
           53248       8    70431    73903    73787    73437
           53248      16   115428   120146   108439   132652
           53248      32   189369   208458   238736   239319
           53248      64   310172   326099   351834   350228
           53248     128   419917   443973   540968   538233
           53248     256   542390   578625   724630   721654
           53248     512   636801   692928   876813   886978
           53248    1024   740769   807593  1023254  1038803
           53248    2048   900703   977706  1744465  1795702
           53248    4096   991434  1218405  2312809  1534298
           53248    8192   172671  1556220  3210650  1240208
           53248   16384  1135860  1732470  3855099  3912755

nconnect=8
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    20164    20622    20499    21020
           53248       4    38006    39090    40008    40093
           53248       8    70803    72965    75611    75827
           53248      16   125845   132516   135011   135602
           53248      32   216442   232697   239348   239241
           53248      64   288013   297895   356983   363912
           53248     128   418932   441833   520451   513015
           53248     256   560464   616810   726013   730965
           53248     512   674367   722693   903227   936461
           53248    1024   761283   840974  1089472  1128827
           53248    2048   943060   924299  1467459  1666917
           53248    4096   970724  1052788  2433414  1938400
           53248    8192  1342030  1089869   464917  3304996
           53248   16384  1458436  1095725  3794363  1635401

nconnect=7
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    20482    21154    21481    21409
           53248       4    39328    40445    41006    40581
           53248       8    75042    77753    80518    79727
           53248      16   131785   136573   139394   138978
           53248      32   150097   209044   249709   250655
           53248      64   316353   333310   380193   383393
           53248     128   427594   453668   573614   573235
           53248     256   568166   611842   751230   753997
           53248     512   655601   718936   909862   920353
           53248    1024   749337   824988  1073221  1092846
           53248    2048   959526   991769  1722507  1835308
           53248    4096  1114485  1273084   824029  2244745
           53248    8192  1096944  1590424  3208102  1612757
           53248   16384   186085  1777460  2446002  3071636

nconnect=6
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    19954    20159    20472    20692
           53248       4    38829    39657    40025    39943
           53248       8    70936    73492    74566    74764
           53248      16   119267   123319   136927   136591
           53248      32   193462   227254   239441   240293
           53248      64   280700   280861   348085   352502
           53248     128   410708   433280   268324   480572
           53248     256   549707   599025   705775   721743
           53248     512   694691   777286   834676   831794
           53248    1024   796161   899669   985672  1011762
           53248    2048   660219  1095097  1442643  1536969
           53248    4096   713024  1097287  2375110  2278199
           53248    8192   961825   814827  1414807  1073586
           53248   16384  1302666   188459   789169  3799328

nconnect=5
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    20083    20853    21387    21790
           53248       4    39346    40634    41595    41911
           53248       8    72275    75203    78950    79016
           53248      16   110484   128308   135731   131166
           53248      32   202718   216528   239493   240653
           53248      64   293191   298468   379034   382413
           53248     128   457944   496666   551294   555308
           53248     256   595181   641156   750500   751126
           53248     512   694337   787317   895434   898956
           53248    1024   761906   854799  1064769  1073980
           53248    2048   946967  1116994  1735369  1746934
           53248    4096   392953  1355423  2615086  2455756
           53248    8192  1356030  1578369  3033668  3172360
           53248   16384  1454587  1743974  3562513  3540975

nconnect=4
                                                             random
random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    20228    20092    21908    22120
           53248       4    38694    39986    41089    41153
           53248       8    75699    78465    80083    80017
           53248      16   102728   130883   135680   141924
           53248      32   220118   231684   240910   249315
           53248      64   302994   321295   385046   386325
           53248     128   457099   488792   564420   563577
           53248     256   586191   676053   767127   776559
           53248     512   715344   782611   899003   906520
           53248    1024   771923   874051  1182348  1256440
           53248    2048   969607  1104706  1557321  1911278
           53248    4096  1179644   981022  1722069  2709534
           53248    8192  1216820  1556373  3159477  3254646
           53248   16384  1508198   605894  3517653  3571029

nconnect=3
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    21481    21763    21988    21311
           53248       4    39828    40888    41669    41768
           53248       8    65010    76085    80491    80466
           53248      16   123527   135609   143423   144154
           53248      32   225695   236990   250957   251665
           53248      64   320309   348847   396364   396967
           53248     128   426707   452220   565097   565103
           53248     256   558951   600620   763477   767196
           53248     512   668986   726410   972622   989905
           53248    1024   782668   839173  1183444  1149741
           53248    2048   974740  1075588  1853002  1885892
           53248    4096  1198605  1308529  1270347  1624458
           53248    8192   936760  1609546  2008581  2949932
           53248   16384   579957  1068755  1254678  1268465

nconnect=2
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    20386    21137    21406    21519
           53248       4    38273    39530    40406    41521
           53248       8    73789    73972    78914    79116
           53248      16   127961   133436   138270   137096
           53248      32   213333   231143   238689   239144
           53248      64   292544   301586   372603   374027
           53248     128   449001   480655   552909   532209
           53248     256   551713   611455   726627   738374
           53248     512   652788   745258   845863   848531
           53248    1024   822491   904270  1080454  1024272
           53248    2048   829847   948519  2001870  1985974
           53248    4096  1198116  1387247  2519900  2503433
           53248    8192  1345305  1475502  2918073  3259019
           53248   16384   634718   475630  3128884  2969906

nconnect=1
                                                              random
 random     bkwd    record    stride
              kB  reclen    write  rewrite    read    reread    read
  write     read   rewrite      read   fwrite frewrite    fread
freread
           53248       2    21288    21799    21638    21763
           53248       4    40599    42412    42758    42762
           53248       8    75734    78713    80072    81414
           53248      16   124331   133874   148128   148421
           53248      32   229738   242286   261479   262589
           53248      64   337174   357993   385598   391051
           53248     128   428862   462394   582345   576003
           53248     256   527788   530506   780829   790614
           53248     512   668147   732605  1071388  1058561
           53248    1024   823391   921211  1218651  1223558
           53248    2048  1016144  1111789  1600626  1585513
           53248    4096  1251567  1436417  1818215  1868426
           53248    8192  1479547  1716916  1804469  1789697
           53248   16384  1435145  1954500  1796230  1799570



On Sun, Apr 30, 2017 at 8:49 AM Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> In the spirit of experimentation, I've put together a set of patches
> that implement setting up multiple TCP connections to the server.
> The connections all go to the same server IP address, so do not
> provide support for multiple IP addresses (which I believe is
> something Andy Adamson is working on).
>
> The feature is only enabled for NFSv4.1 and NFSv4.2 for now; I don't
> feel comfortable subjecting NFSv3/v4 replay caches to this
> treatment yet. It relies on the mount option "nconnect" to specify
> the number of connections to st up. So you can do something like
>   'mount -t nfs -overs=4.1,nconnect=8 foo:/bar /mnt'
> to set up 8 TCP connections to server 'foo'.
>
> Anyhow, feel free to test and give me feedback as to whether or not
> this helps performance on your system.
>
> Trond Myklebust (5):
>   SUNRPC: Allow creation of RPC clients with multiple connections
>   NFS: Add a mount option to specify number of TCP connections to use
>   NFSv4: Allow multiple connections to NFSv4.x (x>0) servers
>   pNFS: Allow multiple connections to the DS
>   NFS: Display the "nconnect" mount option if it is set.
>
>  fs/nfs/client.c             |  2 ++
>  fs/nfs/internal.h           |  2 ++
>  fs/nfs/nfs3client.c         |  3 +++
>  fs/nfs/nfs4client.c         | 13 +++++++++++--
>  fs/nfs/super.c              | 12 ++++++++++++
>  include/linux/nfs_fs_sb.h   |  1 +
>  include/linux/sunrpc/clnt.h |  1 +
>  net/sunrpc/clnt.c           | 17 ++++++++++++++++-
>  net/sunrpc/xprtmultipath.c  |  3 +--
>  9 files changed, 49 insertions(+), 5 deletions(-)
>
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
