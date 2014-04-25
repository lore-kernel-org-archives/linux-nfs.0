Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smarthost02.easyserver.at ([81.16.38.11]:46069 "EHLO
	smarthost02.easyserver.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbaDYKsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 06:48:35 -0400
Received: from email03.easyserver.at (loadbalance01.backbone.easyserver.at [192.168.210.121])
	by smarthost02.easyserver.at (8.14.4/8.14.4) with ESMTP id s3PABhHW014730
	for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 12:11:44 +0200
Received: from [192.168.80.175] (electra.aic.at [193.53.80.80])
	(Authenticated sender: test@hangartest.aic.at)
	by email03.easyserver.at (Postfix) with ESMTPSA id D6B8D23D02
	for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 12:11:43 +0200 (CEST)
Message-ID: <535A34DF.5010302@aic.at>
Date: Fri, 25 Apr 2014 12:11:43 +0200
From: Matthias Leopold <matthias@aic.at>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: multiple mounts of same share on one host?
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,

i've got a (probably rather basic) nfs usage question. i hope this is 
the right place to ask, please tell me otherwise.

i'm moving webspace content to nfs shares. because of suexec 
restrictions i have different paths to different subsets of the content 
on the client, but i wonder if i can still have all of the content in 
one path on one exported nfs share.

example:

i need

/home/content/foo

and

/var/www/content/bar

exported share "/export" could have

/export/foo
/export/bar

AFAICS there are three options:

.) mounting /export twice on different paths on the nfs client
.) mounting /export once and doing a bind mount
.) put foo and bar in different directories and exporting/mounting them 
separately

which of these options would you recommend?

thx very much for help
matthias


