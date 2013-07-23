Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f43.google.com ([209.85.219.43]:34039 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933709Ab3GWUbu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 16:31:50 -0400
Received: by mail-oa0-f43.google.com with SMTP id i7so12522893oag.30
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jul 2013 13:31:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMbhsRSsq0pgS6KvCjiFGneDEJd6zSXsYB_2MCV=sh+6F2muog@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com>
	<CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A@mail.gmail.com>
	<15305281.aClQ8XUG9t@vostro.rjw.lan>
	<CAMbhsRSsq0pgS6KvCjiFGneDEJd6zSXsYB_2MCV=sh+6F2muog@mail.gmail.com>
Date: Tue, 23 Jul 2013 13:31:49 -0700
Message-ID: <CAMbhsRSRcQ-CgCTkRGJJSVSArPqmGRjgxeRBUY0zE94Osxa-nA@mail.gmail.com>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH
 v3 13/16] futex: use freezable blocking call)
From: Colin Cross <ccross@android.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Michael Leun <lkml20130126@newton.leun.net>,
        lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Content-Type: multipart/mixed; boundary=047d7b5d4f2ec4c20204e233aeae
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--047d7b5d4f2ec4c20204e233aeae
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Jul 22, 2013 at 11:28 PM, Colin Cross <ccross@android.com> wrote:
> On Mon, Jul 22, 2013 at 6:41 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> On Monday, July 22, 2013 05:42:49 PM Colin Cross wrote:
>>> On Mon, Jul 22, 2013 at 5:32 PM, Linus Torvalds
>>> <torvalds@linux-foundation.org> wrote:
>>> > On Mon, Jul 22, 2013 at 4:55 PM, Colin Cross <ccross@android.com> wrote:
>>> >>
>>> >> I think the right solution is to add a flag to the freezing task that
>>> >> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
>>> >> normally used on kernel threads, can you see if the attached patch
>>> >> helps?
>>> >
>>> > Hmm. That does seem to be the right thing to do, but I wonder about
>>> > the *other* callers of freeze_processes() IOW, kexec and friends.
>>> >
>>> > So maybe we should do this in {freeze|thaw}_processes() itself, and
>>> > just make the rule be that the caller of freeze_processes() itself is
>>> > obviously not frozen, and has to be the same one that then thaws
>>> > things?
>>> >
>>> > Colin? Rafael? Comments?
>>> >
>>> >                 Linus
>>>
>>> I was worried about clearing the flag in thaw_processes().  If a
>>> kernel thread with PF_NOFREEZE set ever called thaw_processes(), which
>>> autosleep might do, it would clear the flag.  Or if a different thread
>>> called freeze_processes() and thaw_processes().
>>
>> Is that legitimate?
>
> Nothing precludes it today, but I don't see any need for it.  I'll add
> a comment when I add the flag.
>
>>> All the other callers besides the SNAPSHOT_FREEZE ioctl stay in the kernel
>>> between freeze_processes() and thaw_processes(), which makes the fanout of
>>> places that could call try_to_freeze() much more controllable.
>>>
>>> Using a new flag that operates like PF_NOFREEZE but doesn't conflict
>>> with it, or a nofreeze_depth counter, would also work.
>>
>> Well, that would be robust enough.  At least if the purpose of that new flag
>> is clearly specified, people hopefully won't be tempted to optimize it away in
>> the future.
>>
>> Thanks,
>> Rafael
>
> OK, I'll add a new flag.


Michael, can you see if this patch works and doesn't throw any
warnings during suspend or resume?

If the extra process flag is considered too precious for this
(there are only 2 left after this patch) I could get the
same functionality by having freeze_processes() reject calls
from a PF_KTHREAD|PF_NOFREEZE thread, and use PF_KTHREAD to
determine if PF_NOFREEZE should be cleared in thaw_processes().

--047d7b5d4f2ec4c20204e233aeae
Content-Type: application/octet-stream;
	name="0001-power-set-PF_SUSPEND_TASK-flag-on-tasks-that-call-fr.patch"
Content-Disposition: attachment;
	filename="0001-power-set-PF_SUSPEND_TASK-flag-on-tasks-that-call-fr.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hjhk6qi40

RnJvbSAxODhmNTg3MTFhZDE5MzE1YTFhYmFhMDUwMDBkYjlkMzEyYWFhOTNmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDb2xpbiBDcm9zcyA8Y2Nyb3NzQGFuZHJvaWQuY29tPgpEYXRl
OiBNb24sIDIyIEp1bCAyMDEzIDE2OjUzOjE1IC0wNzAwClN1YmplY3Q6IFtQQVRDSF0gcG93ZXI6
IHNldCBQRl9TVVNQRU5EX1RBU0sgZmxhZyBvbiB0YXNrcyB0aGF0IGNhbGwKIGZyZWV6ZV9wcm9j
ZXNzZXMKCkNhbGxpbmcgZnJlZXplX3Byb2Nlc3NlcyBzZXRzIGEgZ2xvYmFsIGZsYWcgdGhhdCB3
aWxsIGNhdXNlIGFueQpwcm9jZXNzIHRoYXQgY2FsbHMgdHJ5X3RvX2ZyZWV6ZSB0byBlbnRlciB0
aGUgcmVmcmlnZXJhdG9yLiAgSXQKc2tpcHMgc2VuZGluZyBhIHNpZ25hbCB0byB0aGUgY3VycmVu
dCB0YXNrLCBidXQgaWYgdGhlIGN1cnJlbnQKdGFzayBldmVyIGhpdHMgdHJ5X3RvX2ZyZWV6ZSBh
bGwgdGhyZWFkcyB3aWxsIGJlIGZyb3plbiBhbmQgdGhlCnN5c3RlbSB3aWxsIGRlYWRsb2NrLgoK
U2V0IGEgbmV3IGZsYWcsIFBGX1NVU1BFTkRfVEFTSywgb24gdGhlIHRhc2sgdGhhdCBjYWxscwpm
cmVlemVfcHJvY2Vzc2VzLiAgVGhlIGZsYWcgbm90aWZpZXMgdGhlIGZyZWV6ZXIgdGhhdCB0aGUg
dGhyZWFkCmlzIGludm9sdmVkIGluIHN1c3BlbmQgYW5kIHNob3VsZCBub3QgYmUgZnJvemVuLiAg
QWxzbyBhZGQgYQpXQVJOX09OIGluIHRoYXdfcHJvY2Vzc2VzIGlmIHRoZSBjYWxsZXIgZG9lcyBu
b3QgaGF2ZSB0aGUKUEZfU1VTUEVORF9UQVNLIGZsYWcgc2V0IHRvIGNhdGNoIGlmIGEgZGlmZmVy
ZW50IHRhc2sgY2FsbHMKdGhhd19wcm9jZXNzZXMgdGhhbiB0aGUgb25lIHRoYXQgY2FsbGVkIGZy
ZWV6ZV9wcm9jZXNzZXMsIGxlYXZpbmcKYSB0YXNrIHdpdGggUEZfU1VTUEVORF9UQVNLIHBlcm1h
bmVudGx5IHNldCBvbiBpdC4KClRocmVhZHMgdGhhdCBzcGF3biBvZmYgYSB0YXNrIHdpdGggUEZf
U1VTUEVORF9UQVNLIHNldCAod2hpY2gKc3dzdXNwIGRvZXMpIHdpbGwgYWxzbyBoYXZlIFBGX1NV
U1BFTkRfVEFTSyBzZXQsIHByZXZlbnRpbmcgdGhlbQpmcm9tIGZyZWV6aW5nIHdoaWxlIHRoZXkg
YXJlIGhlbHBpbmcgd2l0aCBzdXNwZW5kLCBidXQgdGhleSBuZWVkCnRvIGJlIGRlYWQgYnkgdGhl
IHRpbWUgc3VzcGVuZCBpcyB0cmlnZ2VyZWQsIG90aGVyd2lzZSB0aGV5IG1heQpydW4gd2hlbiB1
c2Vyc3BhY2UgaXMgZXhwZWN0ZWQgdG8gYmUgZnJvemVuLiAgQWRkIGEgV0FSTl9PTiBpbgp0aGF3
X3Byb2Nlc3NlcyBpZiBtb3JlIHRoYW4gb25lIHRocmVhZCBoYXMgdGhlIFBGX1NVU1BFTkRfVEFT
SwpmbGFnIHNldC4KClJlcG9ydGVkLWJ5OiBNaWNoYWVsIExldW4gPGxrbWwyMDEzMDEyNkBuZXd0
b24ubGV1bi5uZXQ+ClNpZ25lZC1vZmYtYnk6IENvbGluIENyb3NzIDxjY3Jvc3NAYW5kcm9pZC5j
b20+Ci0tLQogaW5jbHVkZS9saW51eC9zY2hlZC5oICB8ICAxICsKIGtlcm5lbC9mcmVlemVyLmMg
ICAgICAgfCAgMiArLQoga2VybmVsL3Bvd2VyL3Byb2Nlc3MuYyB8IDExICsrKysrKysrKysrCiAz
IGZpbGVzIGNoYW5nZWQsIDEzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1n
aXQgYS9pbmNsdWRlL2xpbnV4L3NjaGVkLmggYi9pbmNsdWRlL2xpbnV4L3NjaGVkLmgKaW5kZXgg
NTBkMDRiOS4uZDcyMjQ5MCAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9zY2hlZC5oCisrKyBi
L2luY2x1ZGUvbGludXgvc2NoZWQuaApAQCAtMTYyOCw2ICsxNjI4LDcgQEAgZXh0ZXJuIHZvaWQg
dGhyZWFkX2dyb3VwX2NwdXRpbWVfYWRqdXN0ZWQoc3RydWN0IHRhc2tfc3RydWN0ICpwLCBjcHV0
aW1lX3QgKnV0LAogI2RlZmluZSBQRl9NRU1QT0xJQ1kJMHgxMDAwMDAwMAkvKiBOb24tZGVmYXVs
dCBOVU1BIG1lbXBvbGljeSAqLwogI2RlZmluZSBQRl9NVVRFWF9URVNURVIJMHgyMDAwMDAwMAkv
KiBUaHJlYWQgYmVsb25ncyB0byB0aGUgcnQgbXV0ZXggdGVzdGVyICovCiAjZGVmaW5lIFBGX0ZS
RUVaRVJfU0tJUAkweDQwMDAwMDAwCS8qIEZyZWV6ZXIgc2hvdWxkIG5vdCBjb3VudCBpdCBhcyBm
cmVlemFibGUgKi8KKyNkZWZpbmUgUEZfU1VTUEVORF9UQVNLIDB4ODAwMDAwMDAgICAgICAvKiB0
aGlzIHRocmVhZCBjYWxsZWQgZnJlZXplX3Byb2Nlc3NlcyBhbmQgc2hvdWxkIG5vdCBiZSBmcm96
ZW4gKi8KIAogLyoKICAqIE9ubHkgdGhlIF9jdXJyZW50XyB0YXNrIGNhbiByZWFkL3dyaXRlIHRv
IHRzay0+ZmxhZ3MsIGJ1dCBvdGhlcgpkaWZmIC0tZ2l0IGEva2VybmVsL2ZyZWV6ZXIuYyBiL2tl
cm5lbC9mcmVlemVyLmMKaW5kZXggOGIyYWZjMS4uYjQ2MmZhMSAxMDA2NDQKLS0tIGEva2VybmVs
L2ZyZWV6ZXIuYworKysgYi9rZXJuZWwvZnJlZXplci5jCkBAIC0zMyw3ICszMyw3IEBAIHN0YXRp
YyBERUZJTkVfU1BJTkxPQ0soZnJlZXplcl9sb2NrKTsKICAqLwogYm9vbCBmcmVlemluZ19zbG93
X3BhdGgoc3RydWN0IHRhc2tfc3RydWN0ICpwKQogewotCWlmIChwLT5mbGFncyAmIFBGX05PRlJF
RVpFKQorCWlmIChwLT5mbGFncyAmIChQRl9OT0ZSRUVaRSB8IFBGX1NVU1BFTkRfVEFTSykpCiAJ
CXJldHVybiBmYWxzZTsKIAogCWlmIChwbV9ub3NpZ19mcmVlemluZyB8fCBjZ3JvdXBfZnJlZXpp
bmcocCkpCmRpZmYgLS1naXQgYS9rZXJuZWwvcG93ZXIvcHJvY2Vzcy5jIGIva2VybmVsL3Bvd2Vy
L3Byb2Nlc3MuYwppbmRleCBmYzBkZjg0Li4wNmVjODg2IDEwMDY0NAotLS0gYS9rZXJuZWwvcG93
ZXIvcHJvY2Vzcy5jCisrKyBiL2tlcm5lbC9wb3dlci9wcm9jZXNzLmMKQEAgLTEwOSw2ICsxMDks
OCBAQCBzdGF0aWMgaW50IHRyeV90b19mcmVlemVfdGFza3MoYm9vbCB1c2VyX29ubHkpCiAKIC8q
KgogICogZnJlZXplX3Byb2Nlc3NlcyAtIFNpZ25hbCB1c2VyIHNwYWNlIHByb2Nlc3NlcyB0byBl
bnRlciB0aGUgcmVmcmlnZXJhdG9yLgorICogVGhlIGN1cnJlbnQgdGhyZWFkIHdpbGwgbm90IGJl
IGZyb3plbi4gIFRoZSBzYW1lIHByb2Nlc3MgdGhhdCBjYWxscworICogZnJlZXplX3Byb2Nlc3Nl
cyBtdXN0IGxhdGVyIGNhbGwgdGhhd19wcm9jZXNzZXMuCiAgKgogICogT24gc3VjY2VzcywgcmV0
dXJucyAwLiAgT24gZmFpbHVyZSwgLWVycm5vIGFuZCBzeXN0ZW0gaXMgZnVsbHkgdGhhd2VkLgog
ICovCkBAIC0xMjAsNiArMTIyLDkgQEAgaW50IGZyZWV6ZV9wcm9jZXNzZXModm9pZCkKIAlpZiAo
ZXJyb3IpCiAJCXJldHVybiBlcnJvcjsKIAorCS8qIE1ha2Ugc3VyZSB0aGlzIHRhc2sgZG9lc24n
dCBnZXQgZnJvemVuICovCisJY3VycmVudC0+ZmxhZ3MgfD0gUEZfU1VTUEVORF9UQVNLOworCiAJ
aWYgKCFwbV9mcmVlemluZykKIAkJYXRvbWljX2luYygmc3lzdGVtX2ZyZWV6aW5nX2NudCk7CiAK
QEAgLTE2OCw2ICsxNzMsNyBAQCBpbnQgZnJlZXplX2tlcm5lbF90aHJlYWRzKHZvaWQpCiB2b2lk
IHRoYXdfcHJvY2Vzc2VzKHZvaWQpCiB7CiAJc3RydWN0IHRhc2tfc3RydWN0ICpnLCAqcDsKKwlz
dHJ1Y3QgdGFza19zdHJ1Y3QgKmN1cnIgPSBjdXJyZW50OwogCiAJaWYgKHBtX2ZyZWV6aW5nKQog
CQlhdG9taWNfZGVjKCZzeXN0ZW1fZnJlZXppbmdfY250KTsKQEAgLTE4MiwxMCArMTg4LDE1IEBA
IHZvaWQgdGhhd19wcm9jZXNzZXModm9pZCkKIAogCXJlYWRfbG9jaygmdGFza2xpc3RfbG9jayk7
CiAJZG9fZWFjaF90aHJlYWQoZywgcCkgeworCQkvKiBObyBvdGhlciB0aHJlYWRzIHNob3VsZCBo
YXZlIFBGX1NVU1BFTkRfVEFTSyBzZXQgKi8KKwkJV0FSTl9PTigocCAhPSBjdXJyKSAmJiAocC0+
ZmxhZ3MgJiBQRl9TVVNQRU5EX1RBU0spKTsKIAkJX190aGF3X3Rhc2socCk7CiAJfSB3aGlsZV9l
YWNoX3RocmVhZChnLCBwKTsKIAlyZWFkX3VubG9jaygmdGFza2xpc3RfbG9jayk7CiAKKwlXQVJO
X09OKCEoY3Vyci0+ZmxhZ3MgJiBQRl9TVVNQRU5EX1RBU0spKTsKKwljdXJyLT5mbGFncyAmPSB+
UEZfU1VTUEVORF9UQVNLOworCiAJdXNlcm1vZGVoZWxwZXJfZW5hYmxlKCk7CiAKIAlzY2hlZHVs
ZSgpOwotLSAKMS44LjMKCg==
--047d7b5d4f2ec4c20204e233aeae--
