From: "Payphone LIOU" <lioupayphone@gmail.com>
Subject: mem leak?
Date: Mon, 1 Sep 2008 11:53:07 +0800
Message-ID: <200809011153057338447@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Cc: "bfields" <bfields@fieldses.org>
To: "linux-nfs" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:19823 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbYIADxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Aug 2008 23:53:15 -0400
Received: by ti-out-0910.google.com with SMTP id b6so949451tic.23
        for <linux-nfs@vger.kernel.org>; Sun, 31 Aug 2008 20:53:14 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, linux-nfs :
			
  in nfs-utils1.1.3,  procedure "get_exportlist()" would malloc() some memory for storing the directories and groups for "showmount". obviously those memory are not released when the procedure ends. once mountd received a signal for quiting itself(eg : kill -9 `pidof mountd`), it will call "killer()" for some exiting-works. but those memory allocated in "get_exportlist()" were not released. memory leak? i am not sure. :-(
 

Payphone LIOU 

