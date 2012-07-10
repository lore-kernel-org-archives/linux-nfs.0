Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.virtall.com ([178.63.195.102]:35600 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043Ab2GJScP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 14:32:15 -0400
Received: from mail.virtall.com (localhost [127.0.0.1])
	by mail.virtall.com (Postfix) with ESMTP id 9659636466F
	for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2012 20:24:02 +0200 (CEST)
Received: from [192.168.1.6] (unknown [60.53.17.228])
	by mail.virtall.com (Postfix) with ESMTPSA id 924F8364595
	for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2012 20:24:01 +0200 (CEST)
Message-ID: <4FFC733D.7050306@wpkg.org>
Date: Wed, 11 Jul 2012 02:23:57 +0800
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: cachefilesd - using multiple cache directories (disks)?
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

is it possible to use cachefilesd with multiple directories (disks)?


The fine manual is not very clear about this:

        dir <path>
               This command specifies the directory containing the root
               of the cache.  It may only specified once per
               configuration file.


This may be interpreted as either:

1) no, it's not possible to use multiple directories with cachefilesd

2) it's not possible to use multiple directories with one cachefilesd 
process, but it's perfectly OK to run multiple instances of cachefilesd 
on one server


Which one is true?


-- 
Tomasz Chmielewski
http://www.ptraveler.com
