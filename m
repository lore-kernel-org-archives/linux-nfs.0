Return-Path: linux-nfs-owner@vger.kernel.org
Received: from imp03.mtu.ru ([62.5.255.20]:34020 "EHLO imp03.mtu.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbaJQSI6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2014 14:08:58 -0400
Message-ID: <54415991.1070907@pavlinux.ru>
Date: Fri, 17 Oct 2014 22:01:53 +0400
From: Pavel Vasilyev <pavel@pavlinux.ru>
Reply-To: pavel@pavlinux.ru
MIME-Version: 1.0
To: Chris Friesen <chris.friesen@windriver.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-ext4@vger.kernel.org,
        tytso@mit.edu, adilger.kernel@dilger.ca,
        linux-rt-users@vger.kernel.org
Subject: Re: Hang writing to nfs-mounted filesystem from client, all nfsd
 tasks on server blocked in D
References: <544156FE.7070905@windriver.com>
In-Reply-To: <544156FE.7070905@windriver.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ext4 it's a kiddy fs, use XFS, Luke!
