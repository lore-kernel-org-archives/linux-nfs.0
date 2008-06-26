From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Upcoming nfs-utils 1.1.3 release.
Date: Thu, 26 Jun 2008 12:59:24 -0400
Message-ID: <76bd70e30806260959s73e90962w40f4ede5106abeff@mail.gmail.com>
References: <48600CCC.5000203@RedHat.com> <48639513.8000402@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "Le Rouzic" <aime.le-rouzic@bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <48639513.8000402@bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2008 at 9:09 AM, Le Rouzic <aime.le-rouzic@bull.net> wrote:
> Could you confirm there will be the Chuck Lever's patches about
> the mount ipv6 patchs series?

I'm not speaking for Steve, but I think my nfs-utils IPv6 patches are
a little too much churn for a small dot release.  And besides, I still
consider them a prototype.

There is a large amount of dust yet to settle for the text-based mount
interface.  I hope nfs-utils 1.1.3 and the 2.6.27 kernel will address
most of these issues.

> Will there be also something about ipv6 server side commands?

Out of curiosity, who is working on server-side user space IPv6 support?

> Steve Dickson a =E9crit :
>
>> FYI...
>>
>> I'm thinking about making a 1.1.3 nfs-utils update release in the
>> relatively near
>> future. I've made about  20 or so commits since the last release so I was
>> thinking
>> that was a nice round number to cut a release...
>> So if your sitting on some patches that you want include please post them
>> to the list. Also if you don't see something in the git tree that should
>> be there (i.e.
>> I missed the patch posting) please bring it to my attention...
>> steved.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>
>
>
> --
> -----------------------------------------------------------------
> Company : Bull, Architect of an Open World TM (www.bull.com)
> Name    : Aime Le Rouzic Mail    : Bull - BP 208 - 38432 Echirolles Cedex=
 -
> France
> E-Mail  : aime.le-rouzic@bull.net
> Phone   : 33 (4) 76.29.75.51
> Fax     : 33 (4) 76.29.75.18
> -----------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- =

I am certain that these presidents will understand the cry of the
people of Bolivia, of the people of Latin America and the whole world,
which wants to have more food and not more cars. First food, then if
something's left over, more cars, more automobiles. I think that life
has to come first.
-- Evo Morales
