From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [Fwd: Re: [2/3] 2.6.23-rc2: known regressions v2]
Date: Wed, 08 Aug 2007 13:41:12 -0400
Message-ID: <1186594872.6699.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-nl8T2oo91QbT7FSnOD+N"
Cc: nfs@lists.sourceforge.net
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIpXD-0008UE-8O
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 10:41:27 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIpXF-0000VR-4n
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 10:41:31 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-nl8T2oo91QbT7FSnOD+N
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Re: the nfsd problem. Shouldn't svc_force_close_socket() be taking the
serv->sv_lock in order to prevent races with svc_sock_enqueue()?

Also, how is the server attempting to prevent races between
svc_sock_put() and the socket callbacks (->sk_data_ready,
->sk_write_space,...)?

Cheers
  Trond

--=-nl8T2oo91QbT7FSnOD+N
Content-Disposition: inline
Content-Description: Forwarded message - Re: [2/3] 2.6.23-rc2: known
	regressions v2
Content-Type: message/rfc822

Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Received: from mail-imap5.uio.no ([unix socket]) by mail-imap5.uio.no
	(Cyrus v2.2.12) with LMTPA; Wed, 08 Aug 2007 19:13:28 +0200
X-Sieve: CMU Sieve 2.2
Delivery-date: Wed, 08 Aug 2007 19:13:28 +0200
Received: from mail-mx9.uio.no ([129.240.10.39]) by mail-imap5.uio.no with
	esmtp (Exim 4.66) (envelope-from <linux-fsdevel-owner@vger.kernel.org>)
	id 1IIp68-0002jc-Ju for trond.myklebust@fys.uio.no;
	Wed, 08 Aug 2007 19:13:28 +0200
Received: from vger.kernel.org ([209.132.176.167]) by mail-mx9.uio.no with
	esmtp (Exim 4.67) (envelope-from <linux-fsdevel-owner@vger.kernel.org>)
	id 1IIp5V-0005bG-Sh for trond.myklebust@fys.uio.no;
	Wed, 08 Aug 2007 19:13:28 +0200
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand id
	S936070AbXHHRMJ (ORCPT <rfc822; trond.myklebust@fys.uio.no>); Wed, 8 Aug
	2007 13:12:09 -0400
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S935610AbXHHRMI
	(ORCPT <rfc822; linux-fsdevel-outgoing>); Wed, 8 Aug 2007 13:12:08 -0400
Received: from ug-out-1314.google.com ([66.249.92.169]:5455 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764421AbXHHRME (ORCPT <rfc822;
	linux-fsdevel@vger.kernel.org>); Wed, 8 Aug 2007 13:12:04 -0400
Received: by ug-out-1314.google.com with SMTP id j3so234095ugf for
	<linux-fsdevel@vger.kernel.org>; Wed, 08 Aug 2007 10:12:03 -0700 (PDT)
DKIM-Signature: a=rsa-sha1; c=relaxed/relaxed; d=gmail.com; s=beta;
	h=domainkey-signature:received:received:message-id:date:user-agent:mime-version:to:cc:subject:references:in-reply-to:x-enigmail-version:content-type:content-transfer-encoding:from;
	b=TJCHb+qV3YIsP3vH4hqZEkgjxFtivLknb5D/Nw/8ASWUEm0n+llxFKttZJ3JD5asSDU1sAraguxqIZZ1BlpjRkKEffSUni4eQFVQ49KxsqA13ignvoGbPqGhTQX7st6AFatIXbTkM9mceZevcUm/BJjr5qMk1SSbKQGxiEbYGTs=
DomainKey-Signature: a=rsa-sha1; c=nofws; d=gmail.com; s=beta;
	h=received:message-id:date:user-agent:mime-version:to:cc:subject:references:in-reply-to:x-enigmail-version:content-type:content-transfer-encoding:from;
	b=ofJVJ/jgjbvAJXkyHA48K0h22yY/oBMqNrA9tSVy9inE+uKiTFcYZiCEonNu1zzclZ/OmxcvaaAkV382pyTIcKczHqb5rlEmqF6Q1OcnFykOQevYLffEjpYEyBP9b4yVmoZ28EL4AlukqNrOdt31GqdXxjfggqWV9qA6ayBdro8=
Received: by 10.67.40.12 with SMTP id s12mr1667854ugj.1186593122744; Wed,
	08 Aug 2007 10:12:02 -0700 (PDT)
Received: from ?192.168.1.70? ( [217.97.160.3]) by mx.google.com with
	ESMTPS id h6sm4039011nfh.2007.08.08.10.11.58 (version=TLSv1/SSLv3
	cipher=RC4-MD5); Wed, 08 Aug 2007 10:12:00 -0700 (PDT)
Message-ID: <46B9F950.2030209@googlemail.com>
Date: Wed, 08 Aug 2007 19:11:44 +0200
User-Agent: Thunderbird 2.0.0.5 (X11/20070719)
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>,
	dth <dth@dth.net>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net, Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Clayton <andrew@digital-domain.net>, linux-mtd@lists.infradead.org,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Thomas Meyer <thomas@m3y3r.de>, Florian Lohoff <flo@rfc822.org>,
	Uwe Bugla <uwe.bugla@gmx.de>
Subject: Re: [2/3] 2.6.23-rc2: known regressions v2
References: <46B9F664.9060600@googlemail.com>
In-Reply-To: <46B9F664.9060600@googlemail.com>
X-Enigmail-Version: 0.95.3
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-fsdevel@vger.kernel.org
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=-0.7, required=12.0,
	autolearn=disabled, AWL=0.966, RCVD_IN_BL_SPAMCOP_NET=1.332,
	UIO_VGER=-3)
X-UiO-Scanned: 58EE94FEB5B339DBB51491F48D94A97F20D0B3FB
X-UiO-SPAM-Test: remote_host: 209.132.176.167 spam_score: -6 maxlevel 60
	minaction 1 bait 0 mail/h: 39 total 441331 max/h 813 blacklist 0
	greylist 0 ratelimit 0

Hi all,

Here is a list of some known regressions in 2.6.23-rc2.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            6
Andi Kleen                             4
Andrew Morton                          4
Linus Torvalds                         4
Al Viro                                3
Cornelia Huck                          3
Jens Axboe                             3
Tejun Heo                              3
David Woodhouse                        2
Hugh Dickins                           2
Peter Zijlstra                         2
Trent Piepho                           2



CPUFREQ

Subject         : ide problems: 2.6.22-git17 working, 2.6.23-rc1* is not
References      : http://lkml.org/lkml/2007/7/27/298
                  http://lkml.org/lkml/2007/7/29/371
Last known good : ?
Submitter       : dth <dth@dth.net>
Caused-By       : Len Brown <lenb@kernel.org>
                  commit f79e3185dd0f8650022518d7624c876d8929061b
Handled-By      : Len Brown <lenb@kernel.org>
Status          : problem is being debugged



FS

Subject         : [NFSD OOPS] 2.6.23-rc1-git10
References      : http://lkml.org/lkml/2007/8/2/462
Last known good : ?
Submitter       : Andrew Clayton <andrew@digital-domain.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



MTD

Subject         : error: implicit declaration of function 'cfi_interleave'
References      : http://lkml.org/lkml/2007/8/6/272
Last known good : ?
Submitter       : Ingo Molnar <mingo@elte.hu>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Networking

Subject         : IP v4 routing is broken
References      : http://www.stardust.webpages.pl/files/tbf/bugs/bug_report01.txt
Last known good : 2.6.22-git2
Submitter       : Uwe Bugla <uwe.bugla@gmx.de>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : New wake ups from sky2
References      : http://lkml.org/lkml/2007/7/20/386
Last known good : ?
Submitter       : Thomas Meyer <thomas@m3y3r.de>
Caused-By       : Stephen Hemminger <shemminger@osdl.org>
                  commit eb35cf60e462491249166182e3e755d3d5d91a28
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-nl8T2oo91QbT7FSnOD+N
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--=-nl8T2oo91QbT7FSnOD+N
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-nl8T2oo91QbT7FSnOD+N--
