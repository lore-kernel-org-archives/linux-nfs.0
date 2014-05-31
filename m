From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Date: Sat, 31 May 2014 18:20:43 +0200
Message-ID: <CAMuHMdU9qEJ=k-Jq7VJZUbM82u0ViqaSLsRBf45EMrQJBLTPxA@mail.gmail.com>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
	<20140531145114.GA3721@localhost.localdomain>
	<6347520.8jMPlVsFjM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: MTD Maling List <linux-mtd@lists.infradead.org>,
        "H. Peter Anvin" <hpa@zytor.com>,
        linux-f2fs-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org,
        "Joseph S. Myers" <joseph@codesourcery.com>,
        Linux-Arch <linux-arch@vger.kernel.org>, linux-cifs@vger.kernel.org,
        scsi <linux-scsi@vger.kernel.org>, linux-afs@lists.infradead.org,
        cluster-devel@redhat.com, coda@cs.cmu.edu,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        codalist@TELEMANN.coda.cs.cmu.edu, fuse-devel@lists.sourceforge.net,
        Richard Cochran <richardcochran@gmail.com>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        "open list:NFS, SUNRPC,
	AND..." <linux-nfs@vger.kernel.org>,
        linux-ntfs-dev@lists.sourceforge.net, samba-technic
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <6347520.8jMPlVsFjM@wuerfel>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 31, 2014 at 5:23 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Saturday 31 May 2014 16:51:15 Richard Cochran wrote:
>> On Fri, May 30, 2014 at 10:01:24PM +0200, Arnd Bergmann wrote:
>> > I picked this because it is a fairly isolated problem, as the
>> > inode time stamps are rarely assigned to any other time values.
>> > As a byproduct of this work, I documented for each of the file
>> > systems we support how long the on-disk format can work[1].
>>
>> Why are some of the time stamp expiration dates marked as "never"?
>
> It's an approximation:
> with 64-bit timestamps, you can represent close to 300 billion
> years, which is way past the time that our planet can sustain
> life of any form[1].

FWIW, the 48-bit second limit of befs marked never happens sooner
than the 32-bit day limit of affs marked as Y11760870.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
