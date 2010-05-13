Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:55495 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab0EMJAH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 05:00:07 -0400
Received: by wwi18 with SMTP id 18so677578wwi.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 02:00:05 -0700 (PDT)
Message-ID: <4BEBBF92.4020705@panasas.com>
Date: Thu, 13 May 2010 12:00:02 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jiri Kortus <sumix@atlas.cz>
CC: linux-nfs@vger.kernel.org
Subject: Re: pNFS-related questions
References: <4BEB283C.1020102@atlas.cz>
In-Reply-To: <4BEB283C.1020102@atlas.cz>
Content-Type: multipart/mixed;
 boundary="------------070703030909040506050600"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------070703030909040506050600
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 05/13/2010 01:14 AM, Jiri Kortus wrote:
> Hi,
> 
> I'd like to ask two questions that are related to pNFS, I hope it's not 
> a problem that I put them in one post even though they aren't related 
> one to the other.
> 
> 1. How to configure a pNFS+exofs setup with multiple OSD targets? I was 
> able to use a setup with one OSD target, one OSD initiator+pNFS metadata 
> server and one client with the help of pNFS mailing list and the 
> instructions from here 
> http://mailman.open-osd.org/pipermail/osd-dev/2009-July/001033.html 
> which seems to be quite clear to me. But I've been thinking about how a 
> setup with more OSDs would look like? (I mean mainly the metadata 
> server). I suppose that I would configure more OSDs in the same way as I 
> did with one. Then how about the pNFS MDS setup? I've been wondering if 
> I could do it this way:
> - login to the targets, then mount /dev/osdX devices for example in 
> /exofs/osdX
> - set up the /etc/exports file in this way:
> /exofs    *(....,fsid=0,pnfs)
> /exofs/osd1    *(....)
> /exofs/osd2    *(....)
> ...
> /exofs/osdX    *(....)
> 

No not at all! ;-)

I'll be a paper about an experiment I did on Panasas labs with 8 osds and
8 clients 1 MDS. I'll be posting the complete scripts I used for setup and tests

So it is much more simple really.

- On X machines you just run ./up to load the osd-target.
  You now have X ip addresses/names
- On MDS/client you change your ./do-osd script to look like this (I'm attaching the complete script)
	login_iscsi_osd()
	{
		echo login into: $1 expect $2
		if $iscsiadm $ISCSI_DBG -m discovery -t sendtargets -p $1 --login; then 
			echo $iscsiadm $ISCSI_DBG -m discovery -t sendtargets -p $1 --login returned error ($?)!
			sleep 3; 
		fi
	
		sleep 1; 
		ls $2 
	}
	And then the do_start changes to:
	start_iscsi_intiator

	start_open_osd

	login_iscsi_osd $IP_OSD0 $DEV_OSD0
	login_iscsi_osd $IP_OSD1 $DEV_OSD1
	login_iscsi_osd $IP_OSD2 $DEV_OSD2
	login_iscsi_osd $IP_OSD3 $DEV_OSD3

	login_iscsi_osd $IP_OSD4 $DEV_OSD4
	login_iscsi_osd $IP_OSD5 $DEV_OSD5
	login_iscsi_osd $IP_OSD6 $DEV_OSD6
	login_iscsi_osd $IP_OSD7 $DEV_OSD7
  
   So basically before hand on client and MDS you login to all osds

- On MDS at one time you do a "format" (see attached script) which mkfs.exofs
  of a file systems with all the OSDs included (Yes exofs is multy device that's
  the all point. mirrors strips and groups are all supported)

  First do a format on MDS. Then do ./do-osd stop. Then do-osd start on MDS and all
  clients. Because format changes the osd-names and they must get updated in memory.

- Then you do the export just exactly as before just one /exp/exofs and exportfs -r.
  (Again this does not change from before)

- Finally you do the do-pnfs start on clients exactlly the same as before.
  There is a single file system. The pnfs/osd protocol takes care of all the
  multiple devices and file layouts.

So to sumerize the only thing different from before is that you need to iscsi login
to more then one OSD. And that the mkfs.exofs command has lots of devices.
(Or you can wait for my paper next week)

Boaz
> - then reload the exports by running "exportfs -r"
> - and finally I would login to the OSDs on the client, load 
> objlayoutdriver and mount the export from MDS with the "minorversion=1" 
> option.
> Could the content of /etc/exports file look like that? Or is it 
> fundamentally wrong? I'd be glad for any advice. I can't test it right 
> now but I have to know how to do it to describe it in my bachelor's thesis.
> 
> 
> 2. I'd like to know how well the IPv6 support in pNFS works - what 
> works, what doesn't, if there are any problems to solve etc., just 
> anything worth to know concerning the IPv6 support.
> 
> Thank you very much in advance.
> 
> Best regards,
> 
> Jiri Kortus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


--------------070703030909040506050600
Content-Type: text/plain;
 name="do-ect2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="do-ect2"

IyEvYmluL3NoCiMKIyBlY3Q6IEV4b2ZzIENsdXN0ZXIgVGVzdAoKbW9kcHJvYmU9L3NiaW4vbW9k
cHJvYmUKc2VydmljZT0vc2Jpbi9zZXJ2aWNlCmlzY3NpYWRtPS9zYmluL2lzY3NpYWRtCgojIE5h
bWUgb2YgaXNjc2kgc2VydmljZS4gLmUuZyBhdCAvZXRjL2luaXQuZC8KSVNDU0k9aXNjc2kKCiMg
OCBvc2RzCkRFVl9PU0QwPS9kZXYvb3NkMApVVUlEMD0iOGMwNzcyYzEtM2I5Yi00NGMwLWJjMjgt
ZGZmNTYzNTRlZDM5IgoKREVWX09TRDE9L2Rldi9vc2QxClVVSUQxPSI0NjgwYTc2OC1lNTg2LTRk
NDItYjRiNi00M2ZkYzVmMDIzMDQiCgpERVZfT1NEMj0vZGV2L29zZDIKVVVJRDI9ImY3MWE1ZGJk
LTQ5YzgtNDU1OC1iYmE4LWExYmIxMmM4YmZmNiIKCkRFVl9PU0QzPS9kZXYvb3NkMwpVVUlEMz0i
ZTQzMmFlNzItODFkNi00OWFiLThiNjEtOTNiNWJiMDI2OGUzIgoKCkRFVl9PU0Q0PS9kZXYvb3Nk
NApVVUlEND0iN2Y1MTgzNjUtMWMzYi00Y2UxLWE1MTEtNDBlYWJhZDFjZTU4IgoKREVWX09TRDU9
L2Rldi9vc2Q1ClVVSUQ1PSI5M2VkYmIwYS1jZjkxLTQ5MmEtYTRhZi05MzFiZTQ5NmZkNTUiCgpE
RVZfT1NENj0vZGV2L29zZDYKVVVJRDY9ImZiZDg5NjZlLTBmZjAtNDk2NS1iYWE1LTRjZWZmODMy
ZDVmOCIKCkRFVl9PU0Q3PS9kZXYvb3NkNwpVVUlENz0iYzE0NjJiYWItOTk5Zi00YTI1LWE5NWQt
ZWJkMTU4ODE4YmYxIgoKSVBfT1NEMD0xMC43MC40LjEyMDozMjYwCklQX09TRDE9MTAuNzAuNC4x
MjE6MzI2MApJUF9PU0QyPTEwLjcwLjQuMTIyOjMyNjAKSVBfT1NEMz0xMC43MC40LjEyMzozMjYw
CgpJUF9PU0Q0PTEwLjcwLjQuMTI0OjMyNjAKSVBfT1NENT0xMC43MC40LjEyNTozMjYwCklQX09T
RDY9MTAuNzAuNC4xMjY6MzI2MApJUF9PU0Q3PTEwLjcwLjQuMTI3OjMyNjAKCiMgbWtleG9mcyBs
YXlvdXQKT09fUk9PVD1gZGlybmFtZSAkMGAKRVhPRlNfRElSPSRPT19ST09UL2ZzL2V4b2ZzClVT
Ul9ESVI9JE9PX1JPT1QvdXNyCk1PVU5URElSPS9tbnQvZXhvZnMKClBJRD0weDEwMDAwClBJRDQ9
MHgyMDAwNApQSUQyPTB4MjAwMDIKUElEMT0weDIwMDAxCgpGT1JNQVRfU0laRT0wClJBSUQ9MApN
SVJST1JTPTAKU1RSSVBFX1BBR0VTPTE2CkdST1VQX1dJRFRIPTAKR1JPVVBfREVQVEg9MAoKZG9f
Y21kKCkKewoJJCogMj4mMSB8IGxvZ2dlciAmCn0KCnN0YXJ0X2lzY3NpX2ludGlhdG9yKCkKewoJ
ZWNobyBzdGFydCBpc2NzaSBzZXJ2aWNlCgoJaWYgISAkc2VydmljZSAkSVNDU0kgc3RhdHVzOyB0
aGVuCgoJCWVjaG8gaXNjc2kgbm90IHN0YXJ0ZWQgcnVubmluZyBbJHNlcnZpY2UgJElTQ1NJIHN0
YXJ0XQoKCQlkb19jbWQgJHNlcnZpY2UgJElTQ1NJIHN0YXJ0IDsKCgkJdW50aWwgY2F0IC9zeXMv
Y2xhc3MvaXNjc2lfdHJhbnNwb3J0L3RjcC9oYW5kbGUgMj4vZGV2L251bGwgOyBkbwoJCQllY2hv
IHdhaXQgZm9yIGlzY3NpLXRyYW5zcG9ydAoJCQlzbGVlcCAxOwoJCWRvbmUKCWZpCgoJc2xlZXAg
NwoJZWNobyBzdGFydCBpc2NzaSBkb25lCn0Kc3RvcF9pc2NzaV9pbnRpYXRvcigpCnsKCWVjaG8g
c3RvcCBpc2NzaQoKCWRvX2NtZCAkc2VydmljZSAkSVNDU0kgc3RvcAoKCXVudGlsIFsgLW4gYCRt
b2Rwcm9iZSAtbCBzY3NpX3RyYW5zcG9ydF9pc2NzaWAgXTsgZG8KCQlzbGVlcCAxOwoJZG9uZQoK
CWVjaG8gc3RvcCBpc2NzaSBkb25lCn0KCklTQ1NJREI9L3Zhci9saWIvaXNjc2kKIyBJU0NTSURC
PS9ldGMvaXNjc2kKZG9faXNjc2lfY2xlYW4oKQp7CglybSAtcmZ2ICRJU0NTSURCL2lmYWNlcy8q
CglybSAtcmZ2ICRJU0NTSURCL25vZGVzLyoKCXJtIC1yZnYgJElTQ1NJREIvc2VuZF90YXJnZXRz
LyoKfQoKIyBJU0NTSV9EQkc9LS1kZWJ1Zz04CiMgdXNhZ2UgbG9naW5faXNjc2lfb3NkICRJUF9P
U0RYICRERVZfT1NEWApsb2dpbl9pc2NzaV9vc2QoKQp7CgllY2hvIGxvZ2luIGludG86ICQxIGV4
cGVjdCAkMgoJaWYgJGlzY3NpYWRtICRJU0NTSV9EQkcgLW0gZGlzY292ZXJ5IC10IHNlbmR0YXJn
ZXRzIC1wICQxIC0tbG9naW47IHRoZW4gCgkJZWNobyAkaXNjc2lhZG0gJElTQ1NJX0RCRyAtbSBk
aXNjb3ZlcnkgLXQgc2VuZHRhcmdldHMgLXAgJDEgLS1sb2dpbiByZXR1cm5lZCBlcnJvciAoJD8p
IQoJCXNsZWVwIDM7IAoJZmkKCglzbGVlcCAxOyAKCWxzICQyIAp9CiMgdXNhZ2UgbG9nb3V0X2lz
Y3NpX29zZCAkSVBfT1NEWCAkREVWX09TRFgKbG9nb3V0X2lzY3NpX29zZCgpCnsKCWVjaG8gbG9n
aW4gb3V0IG9mICQxIGV4cGVjdGVkIG9uICQyCglkb19jbWQgJGlzY3NpYWRtIC1tIG5vZGUgLXAg
JDEgLS1sb2dvdXQKCiMJd2hpbGUgbHMgJDMgMj4vZGV2L251bGw7IGRvIHNsZWVwIDE7IGRvbmUK
CXNsZWVwIDE7Cn0KCnN0YXJ0X29wZW5fb3NkKCkKewojIEluLXRyZWUKCWVjaG8gc3RhcnQgb3Nk
CgoJJG1vZHByb2JlIG9zZDsKfQpzdG9wX29wZW5fb3NkKCkKewojIEluLXRyZWUKCWVjaG8gc3Rv
cCBvc2QKCgkkbW9kcHJvYmUgLS1yZW1vdmUgb3NkOwp9Cgpkb19zdGFydCgpCnsKCXN0YXJ0X2lz
Y3NpX2ludGlhdG9yCgoJc3RhcnRfb3Blbl9vc2QKCglsb2dpbl9pc2NzaV9vc2QgJElQX09TRDAg
JERFVl9PU0QwCglsb2dpbl9pc2NzaV9vc2QgJElQX09TRDEgJERFVl9PU0QxCglsb2dpbl9pc2Nz
aV9vc2QgJElQX09TRDIgJERFVl9PU0QyCglsb2dpbl9pc2NzaV9vc2QgJElQX09TRDMgJERFVl9P
U0QzCgoJbG9naW5faXNjc2lfb3NkICRJUF9PU0Q0ICRERVZfT1NENAoJbG9naW5faXNjc2lfb3Nk
ICRJUF9PU0Q1ICRERVZfT1NENQoJbG9naW5faXNjc2lfb3NkICRJUF9PU0Q2ICRERVZfT1NENgoJ
bG9naW5faXNjc2lfb3NkICRJUF9PU0Q3ICRERVZfT1NENwp9CmRvX3N0b3AoKQp7Cglsb2dvdXRf
aXNjc2lfb3NkICRJUF9PU0Q3ICRERVZfT1NENwoJbG9nb3V0X2lzY3NpX29zZCAkSVBfT1NENiAk
REVWX09TRDYKCWxvZ291dF9pc2NzaV9vc2QgJElQX09TRDUgJERFVl9PU0Q1Cglsb2dvdXRfaXNj
c2lfb3NkICRJUF9PU0Q0ICRERVZfT1NENAoKCWxvZ291dF9pc2NzaV9vc2QgJElQX09TRDMgJERF
Vl9PU0QzCglsb2dvdXRfaXNjc2lfb3NkICRJUF9PU0QyICRERVZfT1NEMgoJbG9nb3V0X2lzY3Np
X29zZCAkSVBfT1NEMSAkREVWX09TRDEKCWxvZ291dF9pc2NzaV9vc2QgJElQX09TRDAgJERFVl9P
U0QwCgoJc3RvcF9pc2NzaV9pbnRpYXRvcgoKCXN0b3Bfb3Blbl9vc2QKfQoKbWtleG9mc19mb3Jt
YXQoKQp7CgkkVVNSX0RJUi9ta2ZzLmV4b2ZzIFwKCQktLXBpZD0kUElEIC0tcmFpZD0kUkFJRCAt
LW1pcnJvcnM9JE1JUlJPUlMgXAoJCS0tc3RyaXBlX3BhZ2VzPSRTVFJJUEVfUEFHRVMgXAoJCS0t
Z3JvdXBfd2lkdGg9JEdST1VQX1dJRFRIIC0tZ3JvdXBfZGVwdGg9JEdST1VQX0RFUFRIIFwKCQkt
LWRldj0kREVWX09TRDAgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAtLW9zZG5hbWU9JFVVSUQwIFwK
CQktLWRldj0kREVWX09TRDEgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAtLW9zZG5hbWU9JFVVSUQx
IFwKCQktLWRldj0kREVWX09TRDIgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAtLW9zZG5hbWU9JFVV
SUQyIFwKCQktLWRldj0kREVWX09TRDMgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAtLW9zZG5hbWU9
JFVVSUQzIFwKCQktLWRldj0kREVWX09TRDQgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAtLW9zZG5h
bWU9JFVVSUQ0IFwKCQktLWRldj0kREVWX09TRDUgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAtLW9z
ZG5hbWU9JFVVSUQ1IFwKCQktLWRldj0kREVWX09TRDYgLS1mb3JtYXQ9JEZPUk1BVF9TSVpFICAt
LW9zZG5hbWU9JFVVSUQ2IFwKCQktLWRldj0kREVWX09TRDcgLS1mb3JtYXQ9JEZPUk1BVF9TSVpF
ICAtLW9zZG5hbWU9JFVVSUQ3Cn0KCm1rZXhvZnNfbWtmczQoKQp7CgkkVVNSX0RJUi9ta2ZzLmV4
b2ZzIFwKCQktLXBpZD0kUElENCAtLXJhaWQ9JFJBSUQgLS1taXJyb3JzPSRNSVJST1JTIFwKCQkt
LXN0cmlwZV9wYWdlcz0kU1RSSVBFX1BBR0VTIFwKCQktLWdyb3VwX3dpZHRoPSRHUk9VUF9XSURU
SCAtLWdyb3VwX2RlcHRoPSRHUk9VUF9ERVBUSCBcCgkJLS1kZXY9JERFVl9PU0QwIFwKCQktLWRl
dj0kREVWX09TRDEgXAoJCS0tZGV2PSRERVZfT1NEMiBcCgkJLS1kZXY9JERFVl9PU0QzCn0KCm1r
ZXhvZnNfbWtmczIoKQp7CgkkVVNSX0RJUi9ta2ZzLmV4b2ZzIFwKCQktLXBpZD0kUElEMiAtLXJh
aWQ9JFJBSUQgLS1taXJyb3JzPSRNSVJST1JTIFwKCQktLXN0cmlwZV9wYWdlcz0kU1RSSVBFX1BB
R0VTIFwKCQktLWdyb3VwX3dpZHRoPSRHUk9VUF9XSURUSCAtLWdyb3VwX2RlcHRoPSRHUk9VUF9E
RVBUSCBcCgkJLS1kZXY9JERFVl9PU0QwIFwKCQktLWRldj0kREVWX09TRDEKfQoKbWtleG9mc19t
a2ZzMSgpCnsKCSRVU1JfRElSL21rZnMuZXhvZnMgXAoJCS0tcGlkPSRQSUQxIC0tcmFpZD0kUkFJ
RCAtLW1pcnJvcnM9JE1JUlJPUlMgXAoJCS0tc3RyaXBlX3BhZ2VzPSRTVFJJUEVfUEFHRVMgXAoJ
CS0tZ3JvdXBfd2lkdGg9JEdST1VQX1dJRFRIIC0tZ3JvdXBfZGVwdGg9JEdST1VQX0RFUFRIIFwK
CQktLWRldj0kREVWX09TRDAKfQoKZG9fbW91bnQoKQp7CglPUFQ9InBpZD0kUElELF9uZXRkZXYi
CgoJbW91bnQgLXQgZXhvZnMgLW8gJE9QVCAkREVWX09TRDAgJE1PVU5URElSCn0KZG9fdW1vdW50
KCkKewoJdW1vdW50ICRNT1VOVERJUgp9CgpQTkZTX1NSVj1jb21wdXRlLTQtMTgKUE5GU19NTlQ9
L21udC9wbmZzCgpkb19wbmZzX3N0YXJ0KCkKewojIAlzZXJ2aWNlIG5mcyBzdGFydAoKCW1rZGly
IC1wICRQTkZTX01OVAoJbW9kcHJvYmUgb2JqbGF5b3V0ZHJpdmVyCgltb3VudCAtdCBuZnM0IC1v
IG1pbm9ydmVyc2lvbj0xICRQTkZTX1NSVjovICRQTkZTX01OVAp9CmRvX3BuZnNfc3RvcCgpCnsK
CXVtb3VudCAkUE5GU19NTlQKCW1vZHByb2JlIC0tcmVtb3ZlIG9iamxheW91dGRyaXZlcgoKIyAJ
c2VydmljZSBuZnMgc3RvcAp9Cgpkb19wbmZzX2RkX3Rlc3QoKQp7CgkjIGxldCBpbiBhbiBJTyBm
b3IgdGhlIGdyYWNlIHBlcmlvZAoJZGQgaWY9L2Rldi96ZXJvIG9mPSRQTkZTX01OVC9kZF8kKGhv
c3RuYW1lKSBicz02NGsgY291bnQ9MTMxMDcyCn0KCnByb21wdCgpCnsKCXJlYWQgLXAgIiQqID4+
PiAiCn0KCmNhc2UgJDEgaW4KaXNjc2lfY2xlYW4pCglkb19pc2NzaV9jbGVhbgoJOzsKCnN0YXJ0
KQoJZWNobyAkMCBTdGFydGluZyB8IGxvZ2dlcgoJZG9fc3RhcnQKCWVjaG8gJDAgSW5pdGlhbGl6
ZWQgfCBsb2dnZXIKCTs7CgpzdG9wKQoJZWNobyAkMCBTdG9wcGluZyB8IGxvZ2dlcgoJZG9fc3Rv
cAoJZWNobyAkMCBTdG9wcGVkIHwgbG9nZ2VyCgk7OwoKZm9ybWF0KQoJcHJvbXB0IG1rZXhvZnNf
Zm9ybWF0Cglta2V4b2ZzX2Zvcm1hdAoJZWNobyAkMCBmb3JtYXQgfCBsb2dnZXIKCTs7Cgpta2Zz
NCkKCXByb21wdCBta2V4b2ZzX21rZnM0Cglta2V4b2ZzX21rZnM0CgllY2hvICQwIG1rZXhvZnNf
bWtmczQgfCBsb2dnZXIKCTs7Cm1rZnMyKQoJcHJvbXB0IG1rZXhvZnNfbWtmczIKCW1rZXhvZnNf
bWtmczIKCWVjaG8gJDAgbWtleG9mc19ta2ZzMiB8IGxvZ2dlcgoJOzsKbWtmczEpCglwcm9tcHQg
bWtleG9mc19ta2ZzMQoJbWtleG9mc19ta2ZzMQoJZWNobyAkMCBta2V4b2ZzX21rZnMxIHwgbG9n
Z2VyCgk7OwoKbW91bnQpCgllY2hvICQwIG1vdW50aW5nIHwgbG9nZ2VyCglkb19tb3VudAoJZWNo
byAkMCBtb3VudGVkIHwgbG9nZ2VyCgk7OwoKdW1vdW50KQoJZWNobyAkMCB1bW91bnRpbmcgfCBs
b2dnZXIKCWRvX3Vtb3VudAoJZWNobyAkMCB1bW91bnRlZCB8IGxvZ2dlcgoJOzsKCnBuZnNfc3Rh
cnQpCgllY2hvICQwIG1vdW50aW5nIHwgbG9nZ2VyCglkb19wbmZzX3N0YXJ0CgllY2hvICQwIG1v
dW50ZWQgfCBsb2dnZXIKCTs7CgpwbmZzX3N0b3ApCgllY2hvICQwIHVtb3VudGluZyB8IGxvZ2dl
cgoJZG9fcG5mc19zdG9wCgllY2hvICQwIHVtb3VudGVkIHwgbG9nZ2VyCgk7OwoKcG5mc19kZF90
ZXN0KQoJZG9fcG5mc19kZF90ZXN0Cgk7OwoKKikKCWVjaG8gIiEhIGlzY3NpX2NsZWFufHN0YXJ0
fHN0b3B8Zm9ybWF0fG1vdW50fHVtb3VudHxwbmZzX3N0YXJ0fHBuZnNfc3RvcHxwbmZzX2RkX3Rl
c3QiCgk7Owplc2FjCgo=

--------------070703030909040506050600--
