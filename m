Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.ukfsn.org ([77.75.108.10]:42392 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932925Ab0EYNxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 09:53:42 -0400
Received: from localhost (smtp-filter.ukfsn.org [192.168.54.205])
	by mail.ukfsn.org (Postfix) with ESMTP id 18E1DDEBCB
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 14:24:08 +0100 (BST)
Received: from mail.ukfsn.org ([192.168.54.25])
	by localhost (smtp-filter.ukfsn.org [192.168.54.205]) (amavisd-new, port 10024)
	with ESMTP id 8RJMde9GIaEY for <linux-nfs@vger.kernel.org>;
	Tue, 25 May 2010 14:24:08 +0100 (BST)
Received: from elm.dgreaves.com (unknown [78.32.229.233])
	by mail.ukfsn.org (Postfix) with ESMTP id E6343DEBC8
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 14:24:07 +0100 (BST)
Received: from ash.dgreaves.com ([10.0.0.111])
	by elm.dgreaves.com with esmtp (Exim 4.69)
	(envelope-from <david@dgreaves.com>)
	id 1OGu75-0006uz-Ev
	for linux-nfs@vger.kernel.org; Tue, 25 May 2010 14:24:07 +0100
Message-ID: <4BFBCF77.2070702@dgreaves.com>
Date: Tue, 25 May 2010 14:24:07 +0100
From: David Greaves <david@dgreaves.com>
To: linux-nfs@vger.kernel.org
Subject: NFS wiki : NFSv4 Enduser doc kerberos
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

FYI I've made an attempt to update this page:
   http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos

If someone could please take a look and correct any errors I've made that would 
be nice.

Some questions:
* should a client have an nfs/<fqdn> principal  (it works without)
* Is the "allow_weak_crypto=true" part still correct?

David

-- 
"Don't worry, you'll be fine; I saw it work in a cartoon once..."
