Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57490 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217Ab1GOBYK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 21:24:10 -0400
Received: by gxk21 with SMTP id 21so358312gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 18:24:09 -0700 (PDT)
Date: Thu, 14 Jul 2011 20:24:09 -0500
Message-ID: <CABrM6wnF-zmobE75cMXstzu0Y-wWwRT-srKxWJeZeVDyv0EEWw@mail.gmail.com>
Subject: Why killing processes that access NFS results in the output directory inaccessible?
From: Peng Yu <pengyu.ut@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi All,

I have an NFS server using the Solaris package version
11.11,REV=2009.11.11, and an NFS client of version 1:1.2.0-4ubuntu4.1
(Ubuntu 10.04LTS).

I use the following Makefile to start (using the command 'make -j')
muliple gunzip processes to unzip the gz files (each gz file is of
several GBs, the decompressed files are about 2 times of the original
files).

I wait for make to run a while so that all the gunzip processes start.
White the process are running, I try to type ctrl-C to kill the make
processes, but it doesn't kill it. Then I use the command 'kill' to
kill make. However, the gnuzip processes are not killed automatically.
I have to use 'kill -9' to kill all gunzip processes. But the
directory txtfiles is not accessible anymore.

Has anybody seen a similar problem when kill processes accessing NFS?
Is there a way to fix this issue by tuning configurations of NFS
client or server?

$ cat Makefile
.PHONY: all

INFILES:=$(wildcard gzfiles/*.txt.gz)
OUTFILES:=$(patsubst gzfiles/%.txt.gz,txtfiles/%.txt,$(INFILES))

all: $(OUTFILES)

$(OUTFILES): txtfiles/%.txt: gzfiles/%.txt.gz
       mkdir -p $(dir $@); gunzip -c $< > $@

clean:
       $(RM) -rf txtfiles

$ ll gzfiles/*
-rw------- 1 nobody nogroup 5853805021 2011-07-13 20:43
gzfiles/28121s_1_export.txt.gz
-rw------- 1 nobody nogroup 4153603765 2011-07-13 20:23
gzfiles/28121s_1_sequence.txt.gz
-rw------- 1 nobody nogroup 3296029841 2011-07-13 20:30
gzfiles/28121s_1_sorted.txt.gz
-rw------- 1 nobody nogroup 5002426991 2011-07-13 20:19
gzfiles/28122s_2_export.txt.gz
-rw------- 1 nobody nogroup 3680452360 2011-07-13 20:35
gzfiles/28122s_2_sequence.txt.gz
-rw------- 1 nobody nogroup 2915028714 2011-07-13 20:46
gzfiles/28122s_2_sorted.txt.gz
-rw------- 1 nobody nogroup 4723638261 2011-07-13 20:47
gzfiles/28123s_3_export.txt.gz
-rw------- 1 nobody nogroup 3562493399 2011-07-13 20:26
gzfiles/28123s_3_sequence.txt.gz
-rw------- 1 nobody nogroup 2824516625 2011-07-13 20:17
gzfiles/28123s_3_sorted.txt.gz
-rw------- 1 nobody nogroup 5642735164 2011-07-13 20:50
gzfiles/28124s_4_export.txt.gz
-rw------- 1 nobody nogroup 4072595214 2011-07-13 20:44
gzfiles/28124s_4_sequence.txt.gz
-rw------- 1 nobody nogroup 3239995460 2011-07-13 20:22
gzfiles/28124s_4_sorted.txt.gz
-rw------- 1 nobody nogroup 4795738475 2011-07-13 20:20
gzfiles/28125s_5_export.txt.gz
-rw------- 1 nobody nogroup 3595104934 2011-07-13 20:32
gzfiles/28125s_5_sequence.txt.gz
-rw------- 1 nobody nogroup 2900122747 2011-07-13 20:51
gzfiles/28125s_5_sorted.txt.gz
-rw------- 1 nobody nogroup 4157690024 2011-07-13 20:41
gzfiles/28126s_6_export.txt.gz
-rw------- 1 nobody nogroup 3187369090 2011-07-13 20:38
gzfiles/28126s_6_sequence.txt.gz
-rw------- 1 nobody nogroup 2426049205 2011-07-13 20:27
gzfiles/28126s_6_sorted.txt.gz
-rw------- 1 nobody nogroup 3857633332 2011-07-13 20:29
gzfiles/28182s_7_export.txt.gz
-rw------- 1 nobody nogroup 3005082989 2011-07-13 20:25
gzfiles/28182s_7_sequence.txt.gz
-rw------- 1 nobody nogroup 2225189693 2011-07-13 20:39
gzfiles/28182s_7_sorted.txt.gz
-rw------- 1 nobody nogroup 3942981571 2011-07-13 20:33
gzfiles/28183s_8_export.txt.gz
-rw------- 1 nobody nogroup 3053659952 2011-07-13 20:37
gzfiles/28183s_8_sequence.txt.gz
-rw------- 1 nobody nogroup 2350022326 2011-07-13 20:36
gzfiles/28183s_8_sorted.txt.gz


-- 
Regards,
Peng
