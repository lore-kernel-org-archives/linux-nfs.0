From: "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [105/105] nfsd4: fix oops on lock failure
Date: Mon, 18 Apr 2011 13:16:43 -0400
Message-ID: <20110418171640.GJ20935@pad.home.fieldses.org>
References: <20110412143559.186613198@clark.kroah.org>
	<87pqokx6lr.fsf@devron.myhome.or.jp>
	<BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com>
	<20110418153236.GC20935@pad.home.fieldses.org>
	<87ipubwnj3.fsf@devron.myhome.or.jp>
	<8762qbwnf1.fsf@devron.myhome.or.jp>
	<87zknnv7id.fsf@devron.myhome.or.jp>
	<BANLkTi=HGzJ4LaZpWsWXrUQVWheS=x7CoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
        Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        akpm@linux-foundation.org, stable@kernel.org, alan@lxorguk.ukuu.org.uk
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <BANLkTi=HGzJ4LaZpWsWXrUQVWheS=x7CoQ@mail.gmail.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 18, 2011 at 09:59:26AM -0700, Linus Torvalds wrote:
> On Mon, Apr 18, 2011 at 9:39 AM, OGAWA Hirofumi
> <hirofumi@mail.parknet.co.jp> wrote:
> >
> > For now, I feel this explain filp leak on my system. the leak is
> > increased slowly (filp, cred_jar, and no nfs* slabs), and leak is on
> > nfs server side.
> >
> > I'll start test of this patch, and see what happens.
> 
> Can somebody ping/remind me when that is verified - preferably about
> _both_ patches, even if it turns out that the first one by Ogawa
> wasn't the one that caused the problem?
> 
> Or can I just assume that the fix will be in Bruce's pull requests some day?

I'll send a pull request when it's sorted out, thanks.

--b.

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
