Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:11157 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751488Ab1CIPav convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 10:30:51 -0500
From: "Assarsson, Emil" <Emil.Assarsson@sonyericsson.com>
To: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Date: Wed, 9 Mar 2011 16:20:42 +0100
Subject: mountd --manage-gids supports max 100 groups?
Message-ID: <2BF070A7A2375D46BA1B6087F8D5DCB678B8E772B8@seldmbx01.corpusers.net>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi All,

Running linux kernel 2.6.32 and nfs-utils 1.2.0 (Ubuntu Lucid)

A regular user in our company usually is member of more than 300 groups. Some user even have up to 600. We want to use the --manage-gids option for mountd. However it seems to me that it is limited to about 100 groups.

The reason seems to be that there is a hard limit for mountd but also that the /proc/net/rpc/auth.unix.gid/channel won't accept more than 1008 characters as input.

I tried to adjust the code for mountd so that it tried to add up to 1000 groups but then I ran in to the channel problem.

Can someone please guide me to the place where I can adjust this limit?


Best regards

Emil Assarsson
Sony Ericsson Mobile Communications AB

"The information in this email, and attachment(s) thereto, is strictly confidential and may be legally privileged. It is intended solely for the named recipient(s), and access to this e-mail, or any attachment(s) thereto, by anyone else is unauthorized. Violations hereof may result in legal actions. Any attachment(s) to this e-mail has been checked for viruses, but please rely on your own virus-checker and procedures. If you contact us by e-mail, we will store your name and address to facilitate communications in the matter concerned. If you do not consent to us storing your name and address for above stated purpose, please notify the sender promptly. Also, if you are not the intended recipient please inform the sender by replying to this transmission, and delete the e-mail, its attachment(s), and any copies of it without, disclosing it."


