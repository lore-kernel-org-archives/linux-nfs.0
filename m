Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34326 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752710AbcKBSHB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Nov 2016 14:07:01 -0400
Subject: Re: [Libtirpc-devel] [PATCH - rpcbind] Provide systemd unit files for
 rpcbind
To: Thorsten Kukuk <kukuk@suse.de>
References: <87oa2q14yc.fsf@notabene.neil.brown.name>
 <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
 <87r36vq85k.fsf@notabene.neil.brown.name>
 <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com>
 <20161102134902.GA6446@suse.de>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        libtirpc-devel@lists.sourceforge.net
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <34b0c398-c77f-41e3-4719-158f2190661c@RedHat.com>
Date: Wed, 2 Nov 2016 14:06:59 -0400
MIME-Version: 1.0
In-Reply-To: <20161102134902.GA6446@suse.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/02/2016 09:49 AM, Thorsten Kukuk wrote:
> On Wed, Nov 02, Steve Dickson wrote:
> 
>> I just took a look and we don't set that... Here is what we
>> set in Fedora
>>
>> RPCBDIR=/tmp
>> %configure CFLAGS="$CFLAGS" LDFLAGS="-pie" \
>>     --enable-warmstarts \
>>     --with-statedir="$RPCBDIR" \
>>     --with-rpcuser="$RPCBUSR" \
>>     --with-nss-modules="files altfiles" \
>>     --enable-libwrap \
>>     --enable-debug
> 
> The rpcbind Makefile has:
> bin_PROGRAMS = rpcbind rpcinfo
> 
> So per default, "make install" should install it into /usr/bin
> and the patch from Niel with bin is correct.
You are correct... In  %install does the following

mv -f ${RPM_BUILD_ROOT}%{_bindir}/rpcbind ${RPM_BUILD_ROOT}/sbin
mv -f ${RPM_BUILD_ROOT}%{_bindir}/rpcinfo ${RPM_BUILD_ROOT}%{_sbindir}

Since rpcbind lives in /usr/sbin in the majority distro
I'm going to change the Makefile.am so "make install" 
will do the right thing... Any objections?

steved.
 
