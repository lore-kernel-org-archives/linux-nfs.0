Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56362 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754421AbdDDV5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Apr 2017 17:57:36 -0400
From: NeilBrown <neilb@suse.com>
To: ChunYu Wang <chunwang@redhat.com>
Date: Wed, 05 Apr 2017 07:57:28 +1000
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>,
        Jianhong Yin <jiyin@redhat.com>,
        Yongcheng Yang <yoyang@redhat.com>
Subject: Re: [PATCH] nfs-server-generator: handle 'noauto' mounts correctly.
In-Reply-To: <CAA2bi7_e+TOfShDacyKSXp6kh0j9bk=nLq01SCftrOk51gu46Q@mail.gmail.com>
References: <87poitv3p4.fsf@notabene.neil.brown.name> <CAA2bi7_e+TOfShDacyKSXp6kh0j9bk=nLq01SCftrOk51gu46Q@mail.gmail.com>
Message-ID: <87vaqjj0on.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Apr 04 2017, ChunYu Wang wrote:

> Hi, Neil,
>
> Thanks for your patch! But seems there still exists same problem on my
> fedora 25 with a patched nfs-utils version, am I made something wrong
> or we just need more patches for fedora family..?
>
> -- I just try it with most simple steps:
> [root@bootp-73-5-219 ~]# cat /etc/fstab |grep boot
> UUID=932047db-24e7-4043-8373-6e87333b9ce1 /boot                   ext4
>    noauto        1 2
> ^^ Set flag to 'noauto'
>
> [root@bootp-73-5-219 ~]# umount /boot; mount -a; mountpoint /boot
> /boot is not a mountpoint
> ^^ umount ready
>
> [root@bootp-73-5-219 ~]# cat /lib/systemd/system/nfs-server.service |grep boot
> RequiresMountsFor= /boot

Why do you have this line in this file?  This is what is causing /boot
to be mounted.
It seems that you don't understand the point of the patch.
The patch modifies the nfs-server systemd generator to *not* including
this line in the generated file if the noauto option is present.

NeilBrown


>
> [root@bootp-73-5-219 ~]# systemctl restart nfs-server
>
> [root@bootp-73-5-219 ~]# mountpoint /boot/
> /boot/ is a mountpoint
> [root@bootp-73-5-219 ~]# mount |grep boot
> /dev/sda1 on /boot type ext4 (rw,relatime,seclabel,data=ordered)
> ^^ mount again automatically
> --
>
> -- Already patched:
> [root@bootp-73-5-219 ~]# rpm -q nfs-utils
> nfs-utils-2.1.1-2.rc1.fc25.x86_64
> [root@bootp-73-5-219 nfs-utils]# grep nfs-server-generator -r ./*.patch
> ./nfs-utils-2.1.2-rc1.patch:diff --git
> a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
> ...
> [root@bootp-73-5-219 nfs-utils]# cat ./nfs-utils.spec |grep -i patch001
> Patch001: nfs-utils-2.1.2-rc1.patch
> %patch001 -p1
> --
>
> Thanks,
> ChunYu Wang
>
>
>
>
>
> On Wed, Feb 8, 2017 at 10:03 AM, NeilBrown <neilb@suse.com> wrote:
>>
>> When this code was written, the systemd documentation stated
>> that "RequiresMountsFor" ignored mountpoints marked as "noauto".
>> Unfortunately this is incorrect.  Consquently a filesystem marked
>> as noauto that is also NFS exported will currently be mounted when
>> the NFS server is started. This is not what people expect.
>>
>> So add a check for the noauto flag.  If any ancestor of a given
>> export point has the noauto flag, no RequiresMountsFor will be
>> generated for that point.
>>
>> Also skip RequiresMountsFor for exports marked 'mountpoint', as their
>> absence is, theoretically, already handled by mountd.
>>
>> URL: https://github.com/systemd/systemd/issues/5249
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  systemd/nfs-server-generator.c | 26 ++++++++++++++++++++++++++
>>  1 file changed, 26 insertions(+)
>>
>> diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
>> index cc99969e9922..4aa65094ca07 100644
>> --- a/systemd/nfs-server-generator.c
>> +++ b/systemd/nfs-server-generator.c
>> @@ -84,6 +84,28 @@ static void systemd_escape(FILE *f, char *path)
>>         }
>>  }
>>
>> +static int has_noauto_flag(char *path)
>> +{
>> +       FILE            *fstab;
>> +       struct mntent   *mnt;
>> +
>> +       fstab = setmntent("/etc/fstab", "r");
>> +       if (!fstab)
>> +               return 0;
>> +
>> +       while ((mnt = getmntent(fstab)) != NULL) {
>> +               int l = strlen(mnt->mnt_dir);
>> +               if (strncmp(mnt->mnt_dir, path, l) != 0)
>> +                       continue;
>> +               if (path[l] && path[l] != '/')
>> +                       continue;
>> +               if (hasmntopt(mnt, "noauto"))
>> +                       break;
>> +       }
>> +       fclose(fstab);
>> +       return mnt != NULL;
>> +}
>> +
>>  int main(int argc, char *argv[])
>>  {
>>         char            *path;
>> @@ -124,6 +146,10 @@ int main(int argc, char *argv[])
>>                 for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
>>                         if (!is_unique(&list, exp->m_export.e_path))
>>                                 continue;
>> +                       if (exp->m_export.e_mountpoint)
>> +                               continue;
>> +                       if (has_noauto_flag(exp->m_export.e_path))
>> +                               continue;
>>                         if (strchr(exp->m_export.e_path, ' '))
>>                                 fprintf(f, "RequiresMountsFor=\"%s\"\n",
>>                                         exp->m_export.e_path);
>> --
>> 2.11.0
>>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljkFsgACgkQOeye3VZi
gbnZDg/+OA+zokVw5x6xptXEPWbUQ9LuS3ntHS2+D7lbpaKDo/WT6pvktGTpbXQ8
w9L7YhaYdoHSMFgj/HFVvT5AJr4o17Ltcsh2jpSxqga0pUroHDAi4T/WMN1nbwfK
dvA51kzySz0VE4MlZcFShWGQnRW/pfNwwm2ZUwzOeIh41hZte/mN7XJ9IB4hmJ0m
AUOrj+pMfJMNVI0/mf024wR3YSTec/YTvvzOsjq0LC3uCLTjBr1OT/cCQFgaGlbP
eRgt2xkJh0P+uVA2GYPhCEL9PyPAD5r9K/48oajc/lk+OkyWvr0vpuBvTMvToM8f
IEUElikOnuvbYivukKxj9KV+0j+g634J2FhQ/n85O7I8kL55E+FzlMUAGUu8kgQv
xhjFGz5mFtbWH4HxWATCjLKXJNtvw1ZqIAOVcA4ZtX+iBD9G4HtVwNwpDsN75hW9
bo9DAA24NSjjb/N4Yf2i0wwx62731soiqnaBHrUfCuZp+7C6tM6TVDedPpVu0kCT
QBuy/Qm2iYfgArivhgiSer0tJFiUx2X2H7WlrnsyPEqCznGTQ3d7cCwAa8ARy5su
syIO90jKADC1E/TAr3oBRL16kDhC5nCaQmGqGyhBJqEh6kF/T8QKsv4gkFfzlGDV
KKFPqBugIN5332Elp5NHX1M/5L33iD+AjUSl9ZsJhMjS96CZN68=
=O4Lg
-----END PGP SIGNATURE-----
--=-=-=--
