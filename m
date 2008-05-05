From: Sten Spans <sten-4ZM2p5qjiQFChlZ7zSldDQ@public.gmane.org>
Subject: Re: [NFS] bug in nfs-utils support/misc/tcpwrapper.c
Date: Mon, 5 May 2008 17:26:45 +0200 (CEST)
Message-ID: <alpine.DEB.0.99999.0805051725110.9075@zaphod.blinkenlights.nl>
References: <alpine.DEB.0.99999.0805030130590.9075@zaphod.blinkenlights.nl>
	<20080505151105.GC8259@fieldses.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="-1463810815-1840548118-1210001205=:9075"
Cc: nfs@lists.sourceforge.net, steved@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34813 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbYEEPmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:42:19 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jt2pQ-0004qZ-NR
	for linux-nfs@vger.kernel.org; Tue, 06 May 2008 01:42:12 +1000
In-Reply-To: <20080505151105.GC8259@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463810815-1840548118-1210001205=:9075
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

On Mon, 5 May 2008, J. Bruce Fields wrote:

> On Sat, May 03, 2008 at 01:49:20AM +0200, Sten Spans wrote:
>>
>> I've been trying to get /etc/netgroup support going on
>> a machine serving nfs mounts to hosts located in various
>> .nl netblocks. Managing hosts this way greatly simplifies
>> hosts.allow and exports management, easily worth any slowdowns
>> during mounting.
>>
>> I did notice a small problem in the tcpwrapper support:
>> (resulting in errors from mountd)
>>
>> 127    /* Check the official name first. */
>> 128    if (hosts_ctl(daemon, "", hp->h_name, ""))
>> 129         return 1;
>>
>> this supplies the resolved hostname in the address field of hosts_ctl
>> which doesn't work. Changing it to:
>>
>> if (hosts_ctl(daemon, hp->h_name, "", ""))
>>
>> does work as expected. The h_aliases check on line 133 probably needs
>> the same change to work as expected.
>
> Yep; looks like a clear bugfix.  (If you have a moment to generate a
> patch (with diff -u) showing both changes, that would probably help

Here ya go (attached as well)

--- support/misc/tcpwrapper.c.orig	2008-05-05 17:22:41.887757664 +0200
+++ support/misc/tcpwrapper.c	2008-05-05 17:24:08.857111820 +0200
@@ -125,12 +125,12 @@
  	   return 0;

     /* Check the official name first. */
-   if (hosts_ctl(daemon, "", hp->h_name, ""))
+   if (hosts_ctl(daemon, hp->h_name, "", ""))
  	return 1;

     /* Check aliases. */
     for (sp = hp->h_aliases; *sp ; sp++) {
-	if (hosts_ctl(daemon, "", *sp, ""))
+	if (hosts_ctl(daemon, *sp, "", ""))
  	    return 1;
     }

-- 
Sten Spans

"There is a crack in everything, that's how the light gets in."
Leonard Cohen - Anthem
---1463810815-1840548118-1210001205=:9075
Content-Type: TEXT/x-diff; name=nfs-utils.diff
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.0.99999.0805051726450.9075-bOEg3dqIyRvlQVwb/tpZ4uvFKoSm8Hlx@public.gmane.org>
Content-Description: 
Content-Disposition: attachment; filename=nfs-utils.diff

LS0tIHN1cHBvcnQvbWlzYy90Y3B3cmFwcGVyLmMub3JpZwkyMDA4LTA1LTA1
IDE3OjIyOjQxLjg4Nzc1NzY2NCArMDIwMA0KKysrIHN1cHBvcnQvbWlzYy90
Y3B3cmFwcGVyLmMJMjAwOC0wNS0wNSAxNzoyNDowOC44NTcxMTE4MjAgKzAy
MDANCkBAIC0xMjUsMTIgKzEyNSwxMiBAQA0KIAkgICByZXR1cm4gMDsNCiAN
CiAgICAvKiBDaGVjayB0aGUgb2ZmaWNpYWwgbmFtZSBmaXJzdC4gKi8NCi0g
ICBpZiAoaG9zdHNfY3RsKGRhZW1vbiwgIiIsIGhwLT5oX25hbWUsICIiKSkN
CisgICBpZiAoaG9zdHNfY3RsKGRhZW1vbiwgaHAtPmhfbmFtZSwgIiIsICIi
KSkNCiAJcmV0dXJuIDE7DQogDQogICAgLyogQ2hlY2sgYWxpYXNlcy4gKi8N
CiAgICBmb3IgKHNwID0gaHAtPmhfYWxpYXNlczsgKnNwIDsgc3ArKykgew0K
LQlpZiAoaG9zdHNfY3RsKGRhZW1vbiwgIiIsICpzcCwgIiIpKQ0KKwlpZiAo
aG9zdHNfY3RsKGRhZW1vbiwgKnNwLCAiIiwgIiIpKQ0KIAkgICAgcmV0dXJu
IDE7DQogICAgfQ0KIA0K

---1463810815-1840548118-1210001205=:9075
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
---1463810815-1840548118-1210001205=:9075
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

---1463810815-1840548118-1210001205=:9075--


