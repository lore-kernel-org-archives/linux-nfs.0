Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38048 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbbDNTjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 15:39:45 -0400
Received: by igbqf9 with SMTP id qf9so23900938igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Apr 2015 12:39:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALs61ue2HBxv6bJrGFoDj43vaYc_Jxf4-RJJ-vRBy9j2wn+tXA@mail.gmail.com>
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
	<CAHQdGtSbn643SVAZ2Y_VzxmS_b-9=+pqPGWGoHtt25hpHpygLw@mail.gmail.com>
	<CALs61uewbb28BcZ=d_qaYWtvUt5-xLGkn1uMXWhpjb_38f8ZtQ@mail.gmail.com>
	<CAHQdGtSZcNj40YFYbKVL7M5ZtBgD278e6ifqM1hpb6BadU4j5A@mail.gmail.com>
	<CALs61udukSrCsDYTyohSQdwbtcvvW672=+Qyit56iTE3qViSSw@mail.gmail.com>
	<CALs61ue2HBxv6bJrGFoDj43vaYc_Jxf4-RJJ-vRBy9j2wn+tXA@mail.gmail.com>
Date: Tue, 14 Apr 2015 15:39:45 -0400
Message-ID: <CALs61ucnKU5J8NJ-unJNsYw_zsPb+_aYbLqndc0yEbtirixqhw@mail.gmail.com>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
From: Gregory Boyce <gregory.boyce@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: multipart/mixed; boundary=001a1135fbe289f5380513b46446
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--001a1135fbe289f5380513b46446
Content-Type: text/plain; charset=UTF-8

On Tue, Apr 14, 2015 at 3:37 PM, Gregory Boyce <gregory.boyce@gmail.com> wrote:
> On Fri, Apr 10, 2015 at 3:04 PM Gregory Boyce <gregory.boyce@gmail.com>
> wrote:
>>
>> On Fri, Apr 10, 2015 at 2:45 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>
>> > No. You are not supposed to be able to work around security issues,
>> > and it is indeed a security issue when a client gets a reply from an
>> > IP address that it does not recognise as being the same as the one it
>> > sent an RPC to.
>>
>> "Working around" security issues is a rather common and accepted
>> practice when there are mitigating controls in place.  It's never a
>> black and white world.
>>
>
>
> The attached patch was able to work around the issue for us until we can get
> the filers working in a more expected manner.  I'm sending it along in case
> anyone else can find a use for it, or if you want to apply it in order to
> give people an option for cases like this.

Re-sending since Google Inbox likes to default to HTML e-mail.

-- 
Greg

--001a1135fbe289f5380513b46446
Content-Type: text/plain; charset=US-ASCII; name="nfs-utils_norewriteopts.diff"
Content-Disposition: attachment; filename="nfs-utils_norewriteopts.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i8hpq82x1

ZGlmZiAtcnUgbmZzLXV0aWxzLTEuMi41Lm9yaWcvdXRpbHMvbW91bnQvc3Ryb3B0cy5jIG5mcy11
dGlscy0xLjIuNS91dGlscy9tb3VudC9zdHJvcHRzLmMKLS0tIG5mcy11dGlscy0xLjIuNS5vcmln
L3V0aWxzL21vdW50L3N0cm9wdHMuYwkyMDE1LTA0LTEzIDIyOjQzOjIwLjAwMDAwMDAwMCArMDAw
MAorKysgbmZzLXV0aWxzLTEuMi41L3V0aWxzL21vdW50L3N0cm9wdHMuYwkyMDE1LTA0LTEzIDIy
OjQ3OjMwLjAwMDAwMDAwMCArMDAwMApAQCAtNDk3LDYgKzQ5NywxNCBAQAogCXN0cnVjdCBwbWFw
IG1udF9wbWFwOwogCiAJLyoKKwkgKiAibm9yZXdyaXRlb3B0cyIgb3B0aW9uIGJ5cGFzc2VzIHRo
ZSBvcHRpb25zIHJld3JpdGluZworCSAqLworCWlmIChwb19jb250YWlucyhvcHRpb25zLCAibm9y
ZXdyaXRlb3B0cyIpID09IFBPX0ZPVU5EKSB7CisJCXBvX3JlbW92ZV9hbGwob3B0aW9ucywgIm5v
cmV3cml0ZW9wdHMiKTsKKwkJcmV0dXJuIDE7CisJfQorCisJLyoKIAkgKiBWZXJzaW9uIGFuZCB0
cmFuc3BvcnQgbmVnb3RpYXRpb24gaXMgbm90IHJlcXVpcmVkCiAJICogYW5kIGRvZXMgbm90IHdv
cmsgZm9yIFJETUEgbW91bnRzLgogCSAqLwo=
--001a1135fbe289f5380513b46446--
