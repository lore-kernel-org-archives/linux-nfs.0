Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:46172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755513AbeDWPTu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 11:19:50 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 769DA417E590
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:19:50 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.46])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 18752215CDC8
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:19:49 +0000 (UTC)
Message-ID: <1524496788.7418.2.camel@redhat.com>
Subject: [PATCH 0/7] nfs-utils: nfsconf cli tool and code tests
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 23 Apr 2018 16:19:48 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series introduces a new cli tool to nfs-utils which provides
for the dumping of the current configuration, querying of individual
settings in a scripting friendly manner and by extension the 
scripted testing and verification of nfsconf functionality.

The previously unreferenced conf_report() is modified to produce
a sorted output, which allows you to --dump the current config in
a way thats easier to diff

As well as some improved error messages a script is included which
tests the current config parsing code by supplying various example
config files and comparing the results of the --dump output.

The cli tool also allows a simple test to check if a config item
has been set, and to retrieve the current value in a way that is
easy to call from a shell script.

As the next stage I hope to implement config setting via the cli 
tool in order to provide an api for automation and management tools

Signed-off-by: Justin Mitchell <jumitche@redhat.com>


