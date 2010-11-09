Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:57810 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754431Ab0KIScn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Nov 2010 13:32:43 -0500
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PFszq-0000Fm-3a
	for linux-nfs@vger.kernel.org; Tue, 09 Nov 2010 10:32:42 -0800
Date: Tue, 9 Nov 2010 10:32:42 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: rpcauth_lookup_credcache hash size
Message-ID: <20101109183242.GA29915@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello!

Just decided to run "perf top" on a web server which seemed to be
CPU-bound and saw this at the top:

             samples  pcnt function                 DSO
             _______ _____ ________________________ __________________

             5261.00 11.9% rpcauth_lookup_credcache [kernel.kallsyms]
             2429.00  5.5% lex_scan                 php4
             2184.00  5.0% thread_group_cputime     [kernel.kallsyms]
             1505.00  3.4% established_get_next     [kernel.kallsyms]
             1083.00  2.5% zendparse                php4
             1055.00  2.4% zend_hash_find           php4
              958.00  2.2% lex_scan                 php5
              905.00  2.1% execute                  php4
              890.00  2.0% memcpy                   /lib/libc-2.7.so

I see this just became configurable, but probably 4 bits (16 buckets?) is
probably a bit small for the default, no?  (hlist_head is just a pointer,
4 or 8 bytes per bucket, so the default is 128 bytes on x64 :))

I guess it really needs to auto-scale...

Simon-
